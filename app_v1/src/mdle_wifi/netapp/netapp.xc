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
#include "netapp.h"
#include "hci.h"
#include "hci_helper.h"
#include "nvmem.h"
#include "wifi_conf_defines.h"

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/
#define MIN_TIMER_VAL_SECONDS               (20)
#define MIN_TIMER_SET(t)    if ((0 != t) && (t < MIN_TIMER_VAL_SECONDS)) \
                            { \
                                t = MIN_TIMER_VAL_SECONDS; \
                            }

#define NETAPP_DHCP_PARAMS_LEN              (20)
#define NETAPP_SET_TIMER_PARAMS_LEN         (20)
#define NETAPP_SET_DEBUG_LEVEL_PARAMS_LEN   (4)
#define NETAPP_PING_SEND_PARAMS_LEN         (16)

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

/*---------------------------------------------------------------------------
 static prototypes
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void netapp_config_mac_adrress(chanend c_wifi, unsigned char mac[])
{
    nvmem_set_mac_address(c_wifi, mac);
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void netapp_dhcp(chanend c_wifi,
                 unsigned int &ip,
                 unsigned int &subnet_mask,
                 unsigned int &default_gateway,
                 unsigned int &dns_server)
{
    // 32 bit to char
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 0), ip);
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 4), subnet_mask);
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 8), default_gateway);
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 12), 0);
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 16), dns_server);

    // fill wlan_tx_buf and send command
    pkg_cmd(c_wifi,
            wlan_tx_buf,
            HCI_NETAPP_DHCP,
            NETAPP_DHCP_PARAMS_LEN);

    // get result
    c_wifi :> int _;
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void netapp_ping_send(chanend c_wifi,
                      unsigned int &ip,
                      unsigned int ping_attempts,
                      unsigned int ping_size,
                      unsigned int ping_timeout)
{
    // 32 bit to char
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 0), ip);
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 4), ping_attempts);
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 8), ping_size);
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 12), ping_timeout);

    // fill wlan_tx_buf and send command
    pkg_cmd(c_wifi,
            wlan_tx_buf,
            HCI_NETAPP_PING_SEND,
            NETAPP_PING_SEND_PARAMS_LEN);

    // get result
    c_wifi :> int _;
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void netapp_ping_report(chanend c_wifi)
{
    // fill wlan_tx_buf and send command
    pkg_cmd(c_wifi,
            wlan_tx_buf,
            HCI_NETAPP_PING_REPORT,
            0);

    // get result
    c_wifi :> int _;
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void netapp_ping_stop(chanend c_wifi)
{
    // fill wlan_tx_buf and send command
    pkg_cmd(c_wifi,
            wlan_tx_buf,
            HCI_NETAPP_PING_STOP,
            0);

    // get result
    c_wifi :> int _;
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void netapp_ipconfig(chanend c_wifi, netapp_ipconfig_retargs_t &ipconfig)
{
    // fill wlan_tx_buf and send command
    pkg_cmd(c_wifi,
            wlan_tx_buf,
            HCI_NETAPP_IPCONFIG,
            0);

    // get result
    c_wifi :> int _;
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void netapp_arp_flush(chanend c_wifi)
{
    // fill wlan_tx_buf and send command
    pkg_cmd(c_wifi,
            wlan_tx_buf,
            HCI_NETAPP_ARP_FLUSH,
            0);

    // get result
    c_wifi :> int _;
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void netapp_timeout_values(chanend c_wifi,
                           unsigned int &dhcp,
                           unsigned int &arp,
                           unsigned int &keep_alive,
                           unsigned int &inactivity)
{
    MIN_TIMER_SET(dhcp)
    MIN_TIMER_SET(arp)
    MIN_TIMER_SET(keep_alive)
    MIN_TIMER_SET(inactivity)

    // 32 bit to char
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 0), dhcp);
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 4), arp);
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 8), keep_alive);
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 12), inactivity);

    // fill wlan_tx_buf and send command
    pkg_cmd(c_wifi,
            wlan_tx_buf,
            HCI_NETAPP_SET_TIMERS,
            NETAPP_SET_TIMER_PARAMS_LEN);

    // get result
    c_wifi :> int _;
}

/*==========================================================================*/
