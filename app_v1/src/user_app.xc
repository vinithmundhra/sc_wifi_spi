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
#include "user_app.h"
#include "wlan.h"
#include "string.h"

#define ENABLE_XSCOPE 0

#if ENABLE_XSCOPE == 1
#include <print.h>
#include <xscope.h>
#endif

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 ports and clocks
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 typedefs
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 global variables
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 static variables
 ---------------------------------------------------------------------------*/
/*
static char my_ssid[] = "XMOS Chennai";
static char my_key[] = "xmos0115";
*/

/*---------------------------------------------------------------------------
 static prototypes
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void user_app(chanend c_wifi)
{
    //int temp_val;

#if ENABLE_XSCOPE == 1
    xscope_register(0, 0, "", 0, "");
    xscope_config_io(XSCOPE_IO_BASIC);
#endif

    // wait for wifi_spi power up
    c_wifi :> int _;

    // start wlan
    wlan_start(c_wifi);


    // Initialize Wi-Fi module
    // User may send params such as SSID, Key, etc...
    /*
    wlan_start(0);
    wlan_disconnect();
    wlan_set_connection_policy(0, 0, 0);
    wlan_connect(WLAN_SEC_WPA2, ssid, my_ssid_len, 0, key, my_key_len);
    wlan_set_event_mask(HCI_EVNT_WLAN_KEEPALIVE     |
                            HCI_EVNT_WLAN_UNSOL_INIT    |
                            HCI_EVNT_WLAN_UNSOL_DHCP    |
                            HCI_EVNT_WLAN_ASYNC_PING_REPORT);
    */

    while(1)
    {
    } // while(1)
}

/*==========================================================================*/
