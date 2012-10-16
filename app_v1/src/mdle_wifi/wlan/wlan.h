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
 ---------------------------------------------------------------------------


 ===========================================================================*/

#ifndef _wlan_h_
#define _wlan_h_

/*---------------------------------------------------------------------------
 nested include files
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/
#define      WLAN_SEC_UNSEC (0)
#define      WLAN_SEC_WEP   (1)
#define      WLAN_SEC_WPA   (2)
#define      WLAN_SEC_WPA2  (3)

/*---------------------------------------------------------------------------
 typedefs
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 global variables
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 extern variables
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 prototypes
 ---------------------------------------------------------------------------*/

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
void wlan_start(chanend c_wifi);

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
void wlan_connect(chanend c_wifi,
                  unsigned int sec_type,
                  char ssid[],
                  int ssid_len,
                  unsigned char key[],
                  int key_len);

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
void wlan_disconnect(chanend c_wifi);

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
void wlan_set_connection_policy(chanend c_wifi,
                                unsigned int should_connect_to_open_ap,
                                unsigned int should_use_fast_connect,
                                unsigned int use_profiles);

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
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
                      unsigned int passphrase_len);

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
void wlan_del_profile(chanend c_wifi, unsigned int index);

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
void wlan_get_scan_results(chanend c_wifi, unsigned int scan_timeout);

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
void wlan_set_scan_params(chanend c_wifi,
                          unsigned int enable,
                          unsigned int min_dwell_time,
                          unsigned int max_dwell_time,
                          unsigned int num_probe_responses,
                          unsigned int channel_mask,
                          int rssi_threshold,
                          unsigned int snr_threshold,
                          unsigned int default_tx_power,
                          unsigned char interval_list[]);

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
void wlan_set_event_mask(chanend c_wifi, unsigned int mask);

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
void wlan_status_get(chanend c_wifi);

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
void wlan_first_time_config_start(chanend c_wifi);

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
void wlan_first_time_config_stop(chanend c_wifi);

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
void wlan_first_time_config_set_prefix(chanend c_wifi, char new_prefix[]);

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
void wifi_spi_start(chanend c_wifi);

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
void wifi_spi_stop(chanend c_wifi);

#endif // _wlan_h_
/*==========================================================================*/
