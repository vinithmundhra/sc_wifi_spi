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

#define ENABLE_XSCOPE 1

#if ENABLE_XSCOPE == 1
#include <print.h>
#include <xscope.h>
#endif

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/
#define HEADERS_SIZE_EVNT   (SPI_HEADER_SIZE + 5)

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
    int power_up = 1;
    int temp_rtn;

    unsigned short spi_read_len;
    unsigned char  type;

#if ENABLE_XSCOPE == 1
    xscope_register(0, 0, "", 0, "");
    xscope_config_io(XSCOPE_IO_BASIC);
#endif

    // Initialize the TiWi-SL and SPI
    spi_tiwisl_init(spi_if, spi_tiwisl_ctrl);

    // Indicate that the WiFi SPI client is now ready
    c_wifi <: power_up;

    while(1)
    {
        select
        {
            case !power_up => spi_tiwisl_ctrl.p_spi_irq when pinseq(0) :> void:
            {
                // nIRQ is low indicating SPI device has some data to send
                spi_read_len = 0;
                type = 0;

                // read 10 bytes from SPI device
                printstrln("wm: spi read first 10 bytes");
                spi_read(spi_if, spi_tiwisl_ctrl, spi_buffer, 10);

                for(int i = 0; i < 10; i++)
                {
                    printintln(spi_buffer[i]);
                }
                type = spi_buffer[SPI_HEADER_SIZE + HCI_PACKET_TYPE_OFFSET];

                // send result
                temp_rtn = 0;
                c_wifi <: temp_rtn;

                /*

                switch(type)
                {
                    case HCI_TYPE_DATA:
                    {
                        spi_read_len = spi_buffer[SPI_HEADER_SIZE + HCI_DATA_LENGTH_OFFSET + 1];
                        spi_read_len += (unsigned short)(spi_buffer[SPI_HEADER_SIZE + HCI_DATA_LENGTH_OFFSET + 1]) << 8;

                        if((HEADERS_SIZE_EVNT + spi_read_len) & 1) { spi_read_len++; }

                        if(spi_read_len)
                        {
                            //spi_read(spi_if, spi_tiwisl_ctrl, spi_buffer, spi_read_len);
                        }
                        break;
                    }
                    case HCI_TYPE_EVNT:
                    {
                        break;
                    }
                    default: break;
                }
                */

                // if its some data, send it to c_wifi_spi
                /*
                 * example: send data to channel
                 * c_wifi_spi <: spi_buffer[];
                 */
                break;
            }



            case c_wifi :> length:
            {
                for(int i = 0; i < length; i++)
                {
                    c_wifi :> spi_buffer[i];
                    printintln(spi_buffer[i]);
                }

                if(power_up)
                {
                    spi_first_write(spi_if, spi_tiwisl_ctrl, spi_buffer, length);
                    power_up = 0;
                }
                else
                {
                    spi_write(spi_if, spi_tiwisl_ctrl, spi_buffer, length);
                }
                break;
            } // case c_wifi :> length:

        } // select

    } // while(1)

}

/*==========================================================================*/
