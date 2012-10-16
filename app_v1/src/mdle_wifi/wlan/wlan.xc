// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*===========================================================================
 Filename: ${file_name}
 Project :
 Author  : ${user}
 Version :
 Purpose
 -----------------------------------------------------------------------------


 ===========================================================================*/

/*---------------------------------------------------------------------------
 include files
 ---------------------------------------------------------------------------*/
#include "wlan.h"
#include "hci.h"
#include "wifi_conf_defines.h"
#include "hci_helper.h"
#include <print.h>

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/
#define SL_SET_SCAN_PARAMS_INTERVAL_LIST_SIZE   (16)
#define SL_SIMPLE_CONFIG_PREFIX_LENGTH          (3)
#define ETH_ALEN                                (6)
#define MAXIMAL_SSID_LENGTH                     (32)

#define SL_PATCHES_REQUEST_DEFAULT              (0)
#define SL_PATCHES_REQUEST_FORCE_HOST           (1)
#define SL_PATCHES_REQUEST_FORCE_NONE           (2)

#define WLAN_SL_INIT_START_PARAMS_LEN           (1)
#define WLAN_PATCH_PARAMS_LENGTH                (8)
#define WLAN_SET_CONNECTION_POLICY_PARAMS_LEN   (12)
#define WLAN_DEL_PROFILE_PARAMS_LEN             (4)
#define WLAN_SET_MASK_PARAMS_LEN                (4)
#define WLAN_SET_SCAN_PARAMS_LEN                (100)
#define WLAN_GET_SCAN_RESULTS_PARAMS_LEN        (4)
#define WLAN_ADD_PROFILE_NOSEC_PARAM_LEN        (24)
#define WLAN_ADD_PROFILE_WEP_PARAM_LEN          (36)
#define WLAN_ADD_PROFILE_WPA_PARAM_LEN          (44)
#define WLAN_CONNECT_PARAM_LEN                  (29)

/*---------------------------------------------------------------------------
 ports and clocks
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 typedefs
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 global variables
 ---------------------------------------------------------------------------*/
sl_info_t sl_info;

/*---------------------------------------------------------------------------
 static variables
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 static prototypes
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 wlan_start
 ---------------------------------------------------------------------------*/
void wlan_start(chanend c_wifi)
{
    // fill api wlan_tx_buf
    wlan_tx_buf[HEADERS_SIZE_CMD] = SL_PATCHES_REQUEST_DEFAULT;

    // fill wlan_tx_buf and send command
    pkg_cmd(c_wifi,
            wlan_tx_buf,
            HCI_CMND_SIMPLE_LINK_START,
            WLAN_SL_INIT_START_PARAMS_LEN);

    // get result
    c_wifi :> int _;


    // fill wlan_tx_buf and send command
    pkg_cmd(c_wifi,
            wlan_tx_buf,
            HCI_CMND_READ_BUFFER_SIZE,
            0);

    // get result
    c_wifi :> int _;

}

/*---------------------------------------------------------------------------
 wlan_connect
 ---------------------------------------------------------------------------*/
void wlan_connect(chanend c_wifi,
                  unsigned int sec_type,
                  char ssid[],
                  int ssid_len,
                  unsigned char key[],
                  int key_len)
{
    int temp_l;
    unsigned char bssid_zero[] = {0, 0, 0, 0, 0, 0};

    // 32 bit to char
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 0), 0x0000001c);
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 4), ssid_len);
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 8), sec_type);
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 12), (0x00000010 + ssid_len));
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 16), key_len);
    // 16 bit 0
    short_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 20), 0);
    // array to chararray
    array_to_stream(wlan_tx_buf, bssid_zero, (HEADERS_SIZE_CMD + 22), ETH_ALEN);
    temp_l = HEADERS_SIZE_CMD + 22 + ETH_ALEN;

    array_to_stream(wlan_tx_buf, ssid, temp_l, ssid_len);
    temp_l += ssid_len;

    array_to_stream(wlan_tx_buf, key, temp_l, key_len);

    // fill wlan_tx_buf and send command
    pkg_cmd(c_wifi,
            wlan_tx_buf,
            HCI_CMND_WLAN_CONNECT,
            (WLAN_CONNECT_PARAM_LEN + ssid_len + key_len - 1));

    // get result
    c_wifi :> int _;

    // wait for connect event
    c_wifi :> int _;

    // wait for dhcp event
    c_wifi :> int _;
}

/*---------------------------------------------------------------------------
 wlan_disconnect
 ---------------------------------------------------------------------------*/
void wlan_disconnect(chanend c_wifi)
{
    // fill wlan_tx_buf and send command
    pkg_cmd(c_wifi,
            wlan_tx_buf,
            HCI_CMND_WLAN_DISCONNECT,
            0);

    // get result
    c_wifi :> int _;
}

/*---------------------------------------------------------------------------
 wlan_set_connection_policy
 ---------------------------------------------------------------------------*/
void wlan_set_connection_policy(chanend c_wifi,
                                unsigned int should_connect_to_open_ap,
                                unsigned int should_use_fast_connect,
                                unsigned int use_profiles)
{
    // 32 bit to char
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 0), should_connect_to_open_ap);
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 4), should_use_fast_connect);
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 8), use_profiles);

    // fill wlan_tx_buf and send command
    pkg_cmd(c_wifi,
            wlan_tx_buf,
            HCI_CMND_WLAN_IOCTL_SET_CONNECTION_POLICY,
            WLAN_SET_CONNECTION_POLICY_PARAMS_LEN);

    // get result
    c_wifi :> int _;
}

/*---------------------------------------------------------------------------
 wlan_add_profile
 ---------------------------------------------------------------------------*/
void wlan_add_profile(chanend c_wifi,
                      unsigned int sec_type,
					  unsigned char ssid[],
					  unsigned int ssid_len,
					  unsigned char bssid[],
                      unsigned int priority,
                      unsigned int pairwisecipher_or_txkeylen,
                      unsigned int groupcipher_txkeyindex,
                      unsigned int key_mgmt,
                      unsigned char pf_or_key[],
                      unsigned int passphrase_len)
{
    unsigned short arg_len;
    unsigned char bssid_zero[] = {0, 0, 0, 0, 0, 0};
    int i = 0;
    int index = HEADERS_SIZE_CMD;

    int_to_stream(wlan_tx_buf, index, sec_type); index += 4;

	// Setup arguments in accordence with the security type

	switch (sec_type)
	{
		//None
	    case WLAN_SEC_UNSEC:
	    {
            int_to_stream(wlan_tx_buf, index, 0x00000014); index += 4;
			int_to_stream(wlan_tx_buf, index, ssid_len); index += 4;
			short_to_stream(wlan_tx_buf, index, 0); index += 2;
            array_to_stream(wlan_tx_buf, bssid_zero, index, ETH_ALEN); index += ETH_ALEN;

            int_to_stream(wlan_tx_buf, index, priority); index += 4;
            array_to_stream(wlan_tx_buf, ssid, index, ssid_len); index += ssid_len;

	        arg_len = WLAN_ADD_PROFILE_NOSEC_PARAM_LEN + ssid_len;
	    }
		break;

		//WEP
	    case WLAN_SEC_WEP:
	    {

            int_to_stream(wlan_tx_buf, index, 0x00000020); index += 4;
			int_to_stream(wlan_tx_buf, index, ssid_len); index += 4;
			short_to_stream(wlan_tx_buf, index, 0); index += 2;
            array_to_stream(wlan_tx_buf, bssid_zero, index, ETH_ALEN); index += ETH_ALEN;

            int_to_stream(wlan_tx_buf, index, priority); index += 4;
			int_to_stream(wlan_tx_buf, index, (0x0000000C + ssid_len)); index += 4;

            int_to_stream(wlan_tx_buf, index, pairwisecipher_or_txkeylen); index += 4;
            int_to_stream(wlan_tx_buf, index, groupcipher_txkeyindex); index += 4;

			array_to_stream(wlan_tx_buf, ssid, index, ssid_len); index += ssid_len;

			for(i = 0; i < 4; i++)
		   	{
            // todo
		   		unsigned char p = pf_or_key[i * pairwisecipher_or_txkeylen];
		   		// VINITH TODO
		   		//array_to_stream(wlan_tx_buf, p, index, pairwisecipher_or_txkeylen); index += 1;
		   	}

	        arg_len = WLAN_ADD_PROFILE_WEP_PARAM_LEN + ssid_len + pairwisecipher_or_txkeylen * 4;

	    }
		break;

		//WPA
		//WPA2
	    case WLAN_SEC_WPA:
	    case WLAN_SEC_WPA2:
	    {
            int_to_stream(wlan_tx_buf, index, 0x00000028); index += 4;
			int_to_stream(wlan_tx_buf, index, ssid_len); index += 4;
			short_to_stream(wlan_tx_buf, index, 0); index += 2;
            array_to_stream(wlan_tx_buf, bssid_zero, index, ETH_ALEN); index += ETH_ALEN;

            int_to_stream(wlan_tx_buf, index, priority); index += 4;
            int_to_stream(wlan_tx_buf, index, pairwisecipher_or_txkeylen); index += 4;
            int_to_stream(wlan_tx_buf, index, groupcipher_txkeyindex); index += 4;
            int_to_stream(wlan_tx_buf, index, key_mgmt); index += 4;
            int_to_stream(wlan_tx_buf, index, (0x00000008 + ssid_len)); index += 4;
            int_to_stream(wlan_tx_buf, index, passphrase_len); index += 4;

			array_to_stream(wlan_tx_buf, ssid, index, ssid_len); index += ssid_len;
            array_to_stream(wlan_tx_buf, pf_or_key, index, passphrase_len); index += passphrase_len;

			arg_len = WLAN_ADD_PROFILE_WPA_PARAM_LEN + ssid_len + passphrase_len;
	    }

        break;
	}

    // Initiate a HCI command
    // fill wlan_tx_buf and send command
    pkg_cmd(c_wifi,
            wlan_tx_buf,
            HCI_CMND_WLAN_IOCTL_ADD_PROFILE,
            arg_len);

    // get result
    c_wifi :> int _;
}

/*---------------------------------------------------------------------------
 wlan_del_profile
 ---------------------------------------------------------------------------*/
void wlan_del_profile(chanend c_wifi, unsigned int index)
{
    // 32 bit to char
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 0), index);

    // fill wlan_tx_buf and send command
    pkg_cmd(c_wifi,
            wlan_tx_buf,
            HCI_CMND_WLAN_IOCTL_DEL_PROFILE,
            WLAN_DEL_PROFILE_PARAMS_LEN);

    // get result
    c_wifi :> int _;
}
/*---------------------------------------------------------------------------
 wlan_set_event_mask
 ---------------------------------------------------------------------------*/
void wlan_get_scan_results(chanend c_wifi, unsigned int scan_timeout)
{
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 0), scan_timeout);

    // fill wlan_tx_buf and send command
    pkg_cmd(c_wifi,
            wlan_tx_buf,
            HCI_CMND_WLAN_IOCTL_GET_SCAN_RESULTS,
            WLAN_GET_SCAN_RESULTS_PARAMS_LEN);

    // get result
    c_wifi :> int _;
}

/*---------------------------------------------------------------------------
 wlan_set_scan_params
 ---------------------------------------------------------------------------*/
void wlan_set_scan_params(chanend c_wifi,
                          unsigned int enable,
                          unsigned int min_dwell_time,
                          unsigned int max_dwell_time,
                          unsigned int num_probe_responses,
                          unsigned int channel_mask,
                          int rssi_threshold,
                          unsigned int snr_threshold,
                          unsigned int default_tx_power,
                          unsigned char interval_list[])
{
    int index = HEADERS_SIZE_CMD;

    int_to_stream(wlan_tx_buf, index, 36); index += 4;
    int_to_stream(wlan_tx_buf, index, enable); index += 4;
    int_to_stream(wlan_tx_buf, index, min_dwell_time); index += 4;
    int_to_stream(wlan_tx_buf, index, max_dwell_time); index += 4;
    int_to_stream(wlan_tx_buf, index, num_probe_responses); index += 4;
    int_to_stream(wlan_tx_buf, index, channel_mask); index += 4;
    int_to_stream(wlan_tx_buf, index, rssi_threshold); index += 4;
    int_to_stream(wlan_tx_buf, index, snr_threshold); index += 4;
    int_to_stream(wlan_tx_buf, index, default_tx_power); index += 4;
    array_to_stream(wlan_tx_buf, interval_list, index, (sizeof(unsigned int) * SL_SET_SCAN_PARAMS_INTERVAL_LIST_SIZE));

    // fill wlan_tx_buf and send command
    pkg_cmd(c_wifi,
            wlan_tx_buf,
            HCI_CMND_WLAN_IOCTL_SET_SCANPARAM,
            WLAN_SET_SCAN_PARAMS_LEN);

    // get result
    c_wifi :> int _;
}

/*---------------------------------------------------------------------------
 wlan_set_event_mask
 ---------------------------------------------------------------------------*/
void wlan_set_event_mask(chanend c_wifi, unsigned int mask)
{
    // 32 bit to char
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 0), mask);

    // fill wlan_tx_buf and send command
    pkg_cmd(c_wifi,
            wlan_tx_buf,
            HCI_CMND_EVENT_MASK,
            WLAN_SET_MASK_PARAMS_LEN);

    // get result
    c_wifi :> int _;
}

/*---------------------------------------------------------------------------
 wlan_status_get
 ---------------------------------------------------------------------------*/
void wlan_status_get(chanend c_wifi)
{
    // fill wlan_tx_buf and send command
    pkg_cmd(c_wifi,
            wlan_tx_buf,
            HCI_CMND_WLAN_IOCTL_STATUSGET,
            0);

    // get result
    c_wifi :> int _;
}

/*---------------------------------------------------------------------------
 wlan_first_time_config_start
 ---------------------------------------------------------------------------*/
void wlan_first_time_config_start(chanend c_wifi)
{
    // fill wlan_tx_buf and send command
    pkg_cmd(c_wifi,
            wlan_tx_buf,
            HCI_CMND_WLAN_IOCTL_SIMPLE_CONFIG_START,
            0);

    // get result
    c_wifi :> int _;

    // wait for FTC to finish - event 0x8080
    c_wifi :> int _;
}

/*---------------------------------------------------------------------------
 wlan_first_time_config_stop
 ---------------------------------------------------------------------------*/
void wlan_first_time_config_stop(chanend c_wifi)
{
    // fill wlan_tx_buf and send command
    pkg_cmd(c_wifi,
            wlan_tx_buf,
            HCI_CMND_WLAN_IOCTL_SIMPLE_CONFIG_STOP,
            0);

    // get result
    c_wifi :> int _;
}

/*---------------------------------------------------------------------------
 wlan_first_time_config_set_prefix
 ---------------------------------------------------------------------------*/
void wlan_first_time_config_set_prefix(chanend c_wifi, char new_prefix[])
{
    array_to_stream(wlan_tx_buf, new_prefix, HEADERS_SIZE_CMD, SL_SIMPLE_CONFIG_PREFIX_LENGTH);
    
    // fill wlan_tx_buf and send command
    pkg_cmd(c_wifi,
            wlan_tx_buf,
            HCI_CMND_WLAN_IOCTL_SIMPLE_CONFIG_SET_PREFIX,
            SL_SIMPLE_CONFIG_PREFIX_LENGTH);

    // get result
    c_wifi :> int _;
}

/*---------------------------------------------------------------------------
 wifi_spi_start
 ---------------------------------------------------------------------------*/
void wifi_spi_start(chanend c_wifi)
{
    int length = 1;
    c_wifi <: length;
    c_wifi <: (unsigned char)(WIFI_START);
    c_wifi :> int _;
}

/*---------------------------------------------------------------------------
 wifi_spi_stop
 ---------------------------------------------------------------------------*/
void wifi_spi_stop(chanend c_wifi)
{
    int length = 1;
    c_wifi <: length;
    c_wifi <: (unsigned char)(WIFI_STOP);
    c_wifi :> int _;
}

/*==========================================================================*/
