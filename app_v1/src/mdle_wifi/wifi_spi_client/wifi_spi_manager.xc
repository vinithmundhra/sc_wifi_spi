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
#include "wifi_spi_manager.h"
#include "spi_tiwisl.h"
#include "wifi_conf_defines.h"
#include "hci_helper.h"
#include "event_handler.h"

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
char spi_buffer[WLAN_TX_BUFFER_SIZE];

/*---------------------------------------------------------------------------
 static variables
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 static prototypes
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void wifi_spi_manager(chanend c_wifi,
                      spi_master_interface &spi_if,
                      spi_tiwisl_ctrl_t &spi_tiwisl_ctrl)
{
    int length;
    unsigned short spi_read_len;
    int start_stop = 1;
    int power_up = 1;

#if ENABLE_XSCOPE == 1
    xscope_register(0, 0, "", 0, "");
    xscope_config_io(XSCOPE_IO_BASIC);
#endif

    while(1)
    {
        select
        {
            case !power_up => spi_tiwisl_ctrl.p_spi_irq when pinseq(0) :> void:
            {
                // nIRQ is low indicating SPI device has some data to send
                spi_read_len = 0;

                // Read the length of SPI packet to read
                spi_read(spi_if, spi_tiwisl_ctrl, spi_buffer, 2, 0);
                spi_read_len = (unsigned short)((unsigned short)(spi_buffer[0] << 8) + (unsigned short)(spi_buffer[1]));

                // Read the rest of packets
                spi_read(spi_if, spi_tiwisl_ctrl, spi_buffer, spi_read_len, 1);

                // Deassert nCS and wait for nIRQ deassertion
                spi_deassert_cs(spi_tiwisl_ctrl);

                // Handle data received from device
                event_handler(c_wifi, spi_buffer, spi_read_len);

                break;
            }



            case c_wifi :> length:
            {

                for(int i = 0; i < length; i++)
                {
                    c_wifi :> spi_buffer[i];
                }

                if(spi_buffer[0] == WIFI_START)
                {
                    // Initialize the TiWi-SL and SPI
                    spi_tiwisl_init(spi_if, spi_tiwisl_ctrl);

                    // Indicate that the WiFi SPI client is now ready
                    c_wifi <: start_stop;
                }
                else if(spi_buffer[0] == WIFI_STOP)
                {
                    // Shut down SPI and deassert power to Wi-Fi module
                    spi_shutdown(spi_if, spi_tiwisl_ctrl);

                    // Reset the power_up variable
                    power_up = 1;

                    // Indicate that the WiFi SPI has now shut down
                    c_wifi <: start_stop;
                }

                else
                {
#if ENABLE_XSCOPE == 1
                    printstr("SPI Write: ");
                    for(int i = 0; i < length; i++)
                    {
                        printint(spi_buffer[i]); printstr("   ");
                    }
                    printstrln(" ");
#endif

                    if(power_up)
                    {
                        spi_first_write(spi_if, spi_tiwisl_ctrl, spi_buffer, length);
                        power_up = 0;
                    }
                    else
                    {
                        spi_write(spi_if, spi_tiwisl_ctrl, spi_buffer, length);
                    }

                } // else - if(spi_buffer[0])

                break;

            } // case c_wifi :> length:

        } // select

    } // while(1)

}

/*==========================================================================*/
