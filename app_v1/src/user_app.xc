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
#include <string.h>
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
//static char my_data[] = "1111111111222222222233333333334444444444555555555566666666667777777777888888888899999999990000000000";

char index[] = "<html><head>  <meta content=\"text/html; charset=ISO-8859-1\" http-equiv=\"content-type\"><title>Welcome to Xmos Webserver</title></head><body>Hello World from Xmos Webserver! </body></html>";
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
    int conn;
    int rx_data;

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
    skt_create(c_wifi, my_skt, AF_INET, SOCK_STREAM, IPPROTO_TCP);

    skt_addr.sa_family = AF_INET;
    // the source port = 80
    skt_addr.sa_data[0] = 0x00; // MSB
    skt_addr.sa_data[1] = 0x50; // LSB
    // all 0 IP address
    skt_addr.sa_data[2] = 0x00;
    skt_addr.sa_data[3] = 0x00;
    skt_addr.sa_data[4] = 0x00;
    skt_addr.sa_data[5] = 0x00;

    // Bind
    skt_bind(c_wifi, my_skt, skt_addr, sizeof(skt_addr_t));

    t :> time; t when timerafter(time + 9000000) :> void;
    t :> time; t when timerafter(time + 9000000) :> void;
    t :> time; t when timerafter(time + 9000000) :> void;
    t :> time; t when timerafter(time + 9000000) :> void;
    t :> time; t when timerafter(time + 9000000) :> void;
    t :> time; t when timerafter(time + 9000000) :> void;

    // listen
    skt_listen(c_wifi, my_skt, 1);

    while(1)
    {
        conn = -1;

        while((conn == -1) || (conn == -2))
        {
            // Blocking. Will stay here until there is a request from a client
            conn = skt_accept(c_wifi, my_skt, skt_addr);
        }

        // Blocking. Will stay here until data received from a client
        rx_data = skt_recv(c_wifi, conn, data_buf, APP_BUF_SIZE, 0);

        if (strncmp(data_buf, "GET ", 4) == 0)
        {
            skt_send(c_wifi, conn, index, strlen(index), 0);
        }

        t :> time; t when timerafter(time + 9000000) :> void;
    } // while(1)
}

/*==========================================================================*/
