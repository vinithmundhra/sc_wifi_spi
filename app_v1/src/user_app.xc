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
#include "nvmem.h"
#include "netapp.h"
#include "wifi_conf_defines.h"
#include <xs1.h>

#define ENABLE_XSCOPE 1

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
static char my_ssid[] = "xms6testap0";
static char my_key[] = "";
static char my_prefix[] = {'x', 'm', 's'};

static char my_data[] = "VINITH_VINITH_VINITH_VINITH_VINITH_VINITH_VINITH_BOOM";

/*---------------------------------------------------------------------------
 static prototypes
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void user_app(chanend c_wifi)
{
    timer t;
    unsigned time;

    unsigned long mip = 0x00000000;
    unsigned long msnm = 0x00000000;
    unsigned long mdg = 0x00000000;
    unsigned long mdns = 0x00000000;

    netapp_ipconfig_retargs_t ipconfig;

#if ENABLE_XSCOPE == 1
    xscope_register(0, 0, "", 0, "");
    xscope_config_io(XSCOPE_IO_BASIC);
#endif

    // start module
    wifi_spi_start(c_wifi);

    // start wlan
    wlan_start(c_wifi);

    // FTC set prefix
    //wlan_first_time_config_set_prefix(c_wifi, my_prefix);

    // FTC start
    //wlan_first_time_config_start(c_wifi);

    //netapp_dhcp(c_wifi, mip, msnm, mdg, mdns);

    // Set connection policy
    wlan_set_connection_policy(c_wifi, 0, 0, 0);

    // stop module
    //wifi_spi_stop(c_wifi);

    // wait for some time !!
    //t :> time;
    //t when timerafter(time + 10000000) :> void;

    // start module
    //wifi_spi_start(c_wifi);

    // start wlan
    //wlan_start(c_wifi);

    // Set the event masks
    //wlan_set_event_mask(c_wifi, (HCI_EVNT_WLAN_KEEPALIVE | HCI_EVNT_WLAN_UNSOL_INIT | HCI_EVNT_WLAN_UNSOL_DHCP | HCI_EVNT_WLAN_ASYNC_PING_REPORT));



    // wlan disconnect
    //wlan_disconnect(c_wifi);


    // wait for some time !!
    t :> time;
    t when timerafter(time + 100000) :> void;

    // Connect!
    printstrln("connecting.....");
    wlan_connect(c_wifi, 0, my_ssid, strlen(my_ssid), my_key, strlen(my_key));

    printstrln("get ip configuration details: ");
    netapp_ipconfig(c_wifi, ipconfig);

    while(1)
    {
    } // while(1)
}

/*==========================================================================*/
