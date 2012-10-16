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
#include "socket.h"
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
#define APP_BUF_SIZE 50

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

static char my_data[] = "1111111111222222222233333333334444444444555555555566666666667777777777888888888899999999990000000000";
int my_skt;

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
    skt_addr_t skt_addr;
    skt_len_t skt_len;
    unsigned char data_buf[APP_BUF_SIZE];

#if ENABLE_XSCOPE == 1
    xscope_register(0, 0, "", 0, "");
    xscope_config_io(XSCOPE_IO_BASIC);
#endif

    // start module
    wifi_spi_start(c_wifi);

    // start wlan
    wlan_start(c_wifi);

    // Set connection policy
    wlan_set_connection_policy(c_wifi, 0, 0, 0);

    t :> time; t when timerafter(time + 9000000) :> void;

    // Connect!
    wlan_connect(c_wifi, 0, my_ssid, strlen(my_ssid), my_key, strlen(my_key));

    // create socket
    skt_create(c_wifi, my_skt, AF_INET, SOCK_DGRAM, IPPROTO_UDP);


    printstrln("sending dummy data packet.....");
    skt_send_to(c_wifi, my_skt, my_data, strlen(my_data), 0, skt_addr, sizeof(skt_addr_t));



    // Bind
    skt_addr.sa_family = AF_INET;
    // the source port = 50000
    skt_addr.sa_data[0] = 0xC3; // MSB
    skt_addr.sa_data[1] = 0x50; // LSB
    // all IP address = 192.168.1.100
    skt_addr.sa_data[2] = 0xC0; // 192
    skt_addr.sa_data[3] = 0xA8; // 168
    skt_addr.sa_data[4] = 0x01; // 1
    skt_addr.sa_data[5] = 0x64; // 100
    skt_bind(c_wifi, my_skt, skt_addr, sizeof(skt_addr_t));

    t :> time; t when timerafter(time + 9000000) :> void;
    t :> time; t when timerafter(time + 9000000) :> void;
    t :> time; t when timerafter(time + 9000000) :> void;
    t :> time; t when timerafter(time + 9000000) :> void;
    t :> time; t when timerafter(time + 9000000) :> void;
    t :> time; t when timerafter(time + 9000000) :> void;


    while(1)
    {
        printstrln("receive data packet.....");
        skt_recv_from(c_wifi, my_skt, data_buf, APP_BUF_SIZE, 0, skt_addr, skt_len);
        t :> time; t when timerafter(time + 9000000) :> void;
    } // while(1)
}

/*==========================================================================*/
