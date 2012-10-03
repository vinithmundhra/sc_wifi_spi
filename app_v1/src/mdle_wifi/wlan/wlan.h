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
                  unsigned long sec_type,
                  char ssid[],
                  long ssid_len,
                  unsigned char key[],
                  long key_len);

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
                                unsigned long should_connect_to_open_ap,
                                unsigned long should_use_fast_connect,
                                unsigned long use_profiles);

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
void wlan_add_profile(chanend c_wifi,
                      unsigned long sec_type,
					  unsigned char ssid[],
					  unsigned long ssid_len,
					  unsigned char bssid[],
                      unsigned long priority,
                      unsigned long pairwisecipher_or_txkeylen,
                      unsigned long groupcipher_txkeyindex,
                      unsigned long key_mgmt,
                      unsigned char pf_or_key[],
                      unsigned long passphrase_len);

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
void wlan_del_profile(chanend c_wifi, unsigned long index);

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
void wlan_get_scan_results(chanend c_wifi, unsigned long scan_timeout);

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
void wlan_set_scan_params(chanend c_wifi,
                          unsigned long enable,
                          unsigned long min_dwell_time,
                          unsigned long max_dwell_time,
                          unsigned long num_probe_responses,
                          unsigned long channel_mask,
                          long rssi_threshold,
                          unsigned long snr_threshold,
                          unsigned long default_tx_power,
                          unsigned char interval_list[]);

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
void wlan_set_event_mask(chanend c_wifi, unsigned long mask);

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
