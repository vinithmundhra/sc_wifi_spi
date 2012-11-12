// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*===========================================================================
 Info
 ----

 ===========================================================================*/

/*---------------------------------------------------------------------------
 include files
 ---------------------------------------------------------------------------*/
#include "tiwisl_event_handler.h"
#include "wifi_tiwisl_server.h"
#include "wifi_tiwisl_spi.h"
#include "hci_defines.h"
#include "xtcp_client.h"
#include "xtcp_cmd.h"
#include "hci_pkg.h"

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
unsigned char tiwisl_buf[TIWISL_BUF_SIZE];

/*---------------------------------------------------------------------------
 static variables
 ---------------------------------------------------------------------------*/
static int power_up = 1;

/*---------------------------------------------------------------------------
 static prototypes
 ---------------------------------------------------------------------------*/

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
static void tiwisl_write(spi_master_interface &tiwisl_spi,
                         wifi_tiwisl_ctrl_ports_t &tiwisl_ctrl,
                         unsigned char buf[],
                         int len);

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
static void tiwisl_read(spi_master_interface &tiwisl_spi,
                        wifi_tiwisl_ctrl_ports_t &tiwisl_ctrl,
                        unsigned char buf[]);

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
static void send_and_wait_for_response(chanend c_xtcp,
                                       spi_master_interface &tspi,
                                       wifi_tiwisl_ctrl_ports_t &tctrl,
                                       unsigned char buf[],
                                       int length,
                                       int connid);

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
static void tiwisl_write(spi_master_interface &tiwisl_spi,
                         wifi_tiwisl_ctrl_ports_t &tiwisl_ctrl,
                         unsigned char buf[],
                         int len)
{
    if(power_up)
    {
        wifi_tiwisl_spi_first_write(tiwisl_spi, tiwisl_ctrl, buf, len);
        power_up = 0;
    }
    else
    {
        wifi_tiwisl_spi_write(tiwisl_spi, tiwisl_ctrl, buf, len);
    }
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
static void tiwisl_read(spi_master_interface &tiwisl_spi,
                        wifi_tiwisl_ctrl_ports_t &tiwisl_ctrl,
                        unsigned char buf[])
{
    // nIRQ is low indicating SPI device has some data to send
    int spi_read_len = 0;

    // Read the length of SPI packet to read
    wifi_tiwisl_spi_read(tiwisl_spi, tiwisl_ctrl, buf, 2, 0);
    spi_read_len = (unsigned short)((unsigned short)(buf[0] << 8) + (unsigned short)(buf[1]));

    // Read the rest of packets
    wifi_tiwisl_spi_read(tiwisl_spi, tiwisl_ctrl, buf, spi_read_len, 1);

    // Deassert nCS and wait for nIRQ deassertion
    wifi_tiwisl_spi_deassert_cs(tiwisl_ctrl);
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
static void send_and_wait_for_response(chanend c_xtcp,
                                       spi_master_interface &tspi,
                                       wifi_tiwisl_ctrl_ports_t &tctrl,
                                       unsigned char buf[],
                                       int length,
                                       int connid)
{
    tiwisl_write(tspi, tctrl, buf, length);
    tiwisl_read(tspi, tctrl, buf);
    tiwisl_event_handler(c_xtcp, connid, buf[0]);
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void wifi_tiwisl_server(chanend c_xtcp,
                        spi_master_interface &tiwisl_spi,
                        wifi_tiwisl_ctrl_ports_t &tiwisl_ctrl)
{
    xtcp_cmd_t cmd;
    int conn_id;
    int len = 0;

#if ENABLE_XSCOPE == 1
    xscope_register(0, 0, "", 0, "");
    xscope_config_io(XSCOPE_IO_BASIC);
#endif

    while(1)
    {
        select
        {
            // =========================================
            // Handle commands from user
            // =========================================
            case c_xtcp :> cmd:
            {
                c_xtcp :> conn_id;

                switch(cmd)
                {
                    case XTCP_CMD_WIFI_ON:
                    {
                        // Initialize the TiWi-SL and SPI
                        wifi_tiwisl_spi_init(tiwisl_spi, tiwisl_ctrl);

                        // Send simple link start command
                        len = hci_pkg_wifi_on();
                        send_and_wait_for_response(c_xtcp, tiwisl_spi, tiwisl_ctrl, tiwisl_buf, len, conn_id);

                        // Send read buffer command
                        len = hci_pkg_read_buffer_size();
                        send_and_wait_for_response(c_xtcp, tiwisl_spi, tiwisl_ctrl, tiwisl_buf, len, conn_id);

                        // Set event mask
                        len = hci_pkg_set_event_mask(HCI_EVNT_WLAN_UNSOL_CONNECT            |
                                                     HCI_EVNT_WLAN_UNSOL_DISCONNECT         |
                                                     HCI_EVNT_WLAN_ASYNC_SIMPLE_CONFIG_DONE |
                                                     HCI_EVNT_WLAN_ASYNC_PING_REPORT        |
                                                     HCI_EVNT_WLAN_KEEPALIVE );

                        send_and_wait_for_response(c_xtcp, tiwisl_spi, tiwisl_ctrl, tiwisl_buf, len, conn_id);

                        // Send set connection policy command
                        len = hci_pkg_wlan_set_connection_policy(0, 0, 0);
                        send_and_wait_for_response(c_xtcp, tiwisl_spi, tiwisl_ctrl, tiwisl_buf, len, conn_id);

                        // Power up sequence finished. Send dummy value.
                        c_xtcp <: power_up;

                        break;

                    } // case XTCP_CMD_WIFI_ON:

                    case XTCP_CMD_WIFI_OFF:
                    {
                        wifi_tiwisl_spi_shutdown(tiwisl_spi, tiwisl_ctrl);
                        power_up = 1;

                        break;
                    } // case XTCP_CMD_WIFI_OFF:


                    case XTCP_CMD_CONNECT:
                    {
                        wifi_ap_config_t ap_config;
                        slave
                        {
                            c_xtcp :> ap_config;
                        }

                        // Send wlan connect command
                        len = hci_pkg_wlan_connect(ap_config);
                        tiwisl_write(tiwisl_spi, tiwisl_ctrl, tiwisl_buf, len);

                        break;
                    } // case XTCP_CMD_CONNECT


                    case XTCP_CMD_GET_IPCONFIG:
                    {
                        xtcp_ipconfig_t ipconfig;
                        tiwisl_get_ipconfig(ipconfig);
                        master
                        {
                            for (int i=0;i<4;i++) { c_xtcp <: ipconfig.ipaddr[i]; }
                            for (int i=0;i<4;i++) { c_xtcp <: ipconfig.netmask[i]; }
                            for (int i=0;i<4;i++) { c_xtcp <: ipconfig.gateway[i]; }
                        }
                        break;
                    } // case XTCP_CMD_GET_IPCONFIG:

                    case XTCP_CMD_LISTEN:
                    {
                        int port_number;
                        xtcp_protocol_t p;

                        slave
                        {
                            c_xtcp :> port_number;
                            c_xtcp :> p;
                        }

                        // create a socket
                        len = hci_pkg_skt_create(p);
                        send_and_wait_for_response(c_xtcp, tiwisl_spi, tiwisl_ctrl, tiwisl_buf, len, conn_id);

                        // socket bind
                        len = hci_pkg_skt_bind(conn_id, port_number);
                        send_and_wait_for_response(c_xtcp, tiwisl_spi, tiwisl_ctrl, tiwisl_buf, len, conn_id);

                        // socket listen
                        len = hci_pkg_skt_listen(conn_id);
                        send_and_wait_for_response(c_xtcp, tiwisl_spi, tiwisl_ctrl, tiwisl_buf, len, conn_id);

                        break;
                    } // case XTCP_CMD_LISTEN:

                } // switch(cmd)

                break;

            } // case c_xtcp :> cmd;


            // =========================================
            // Handle Events from TiWiSL
            // =========================================
            case !power_up => tiwisl_ctrl.p_spi_irq when pinseq(0) :> void:
            {
                // Read response
                tiwisl_read(tiwisl_spi, tiwisl_ctrl, tiwisl_buf);
                // Handle response
                tiwisl_event_handler(c_xtcp, conn_id, tiwisl_buf[0]);

                break;
            } // case !power_up => tiwisl_ctrl.p_spi_irq when pinseq(0) :> void:
        } // select
    } // while(1)
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/

/*==========================================================================*/
