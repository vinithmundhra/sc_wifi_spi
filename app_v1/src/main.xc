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
#include <platform.h>
#include <xs1.h>

#include "wifi_spi.h"
#include "spi_master.h"

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 ports and clocks
 ---------------------------------------------------------------------------*/
on stdcore[0]: spi_master_interface spi_if =
{
  XS1_CLKBLK_1,
  XS1_CLKBLK_2,
  XS1_PORT_1L, // MOSI
  XS1_PORT_1M, // CLK
  XS1_PORT_1O, // MISO
};

on stdcore[0]: spi_tiwisl_ctrl_t spi_tiwisl_ctrl =
{
    XS1_PORT_1P, // nCS
    XS1_PORT_1N, // nIRQ
    XS1_PORT_1K  // Wifi power enable
};

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
 prototypes
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 implementation
 ---------------------------------------------------------------------------*/

/*==========================================================================*/
/**
 *  main entry point
 *
 **/
int main(void)
{
    chan c_wifi_app;

    par
    {
        on stdcore[0]: t_wifi(c_wifi_app, spi_tiwisl_ctrl.p_spi_irq);
    }

    return 0;
}

/*==========================================================================*/
