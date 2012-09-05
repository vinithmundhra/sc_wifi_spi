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
#include <xs1.h>
#include <print.h>
#include "wifi_spi.h"
#include "spi_handler.h"
#include "wifi_init.h"

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/
// Handle unsolicited commands every 500 ms
#define TIME_UNSOLICITED_COMMAND_HANDLE   50000000

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
 t_wifi
 ---------------------------------------------------------------------------*/
void t_wifi(chanend c_wifi_app, in port p_spi_irq)
{
    timer t;
    unsigned time;

    wifi_spi_init();

    t :> time;
    time += TIME_UNSOLICITED_COMMAND_HANDLE;
#if 0
    while(1)
    {
        select
        {
            case p_spi_irq when pinseq(0) :> void:
            {
                printstrln("IRQ Low");
                spih_irq_handler();
                break;
            } // case p_spi_irq when pinseq(0) :> void:

            case t when timerafter(time) :> void:
            {
                //hci_unsolicited_event_handler();
                time += TIME_UNSOLICITED_COMMAND_HANDLE;
                break;
            } // case t when timerafter(time) :> void:

            /*
            case c_wifi_app :> int x:
            {
                application_specific();
                break;
            }
            */

        } // select
    } // while(1)
#endif
}

/*---------------------------------------------------------------------------
 implementation2
 ---------------------------------------------------------------------------*/

/*==========================================================================*/
