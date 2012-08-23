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
 ---------------------------------------------------------------------------


 ===========================================================================*/

#ifndef _wifi_spi_h_
#define _wifi_spi_h_

/*---------------------------------------------------------------------------
 nested include files
 ---------------------------------------------------------------------------*/
#include "spi_master_tiwisl.h"

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 typedefs
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 global variables
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 extern variables
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 prototypes
 ---------------------------------------------------------------------------*/

/*==========================================================================*/
/**
 *  The Wi-Fi thread. It must initialize SPI and Wi-Fi modules with correct
 *  settings.
 *
 *  \param c_wifi   channel connecting with the app and this thread
 *  \param spi_if   SPI interface ports (5 wire)
 *  \param p_wifi_pwr_en    Wi-Fi power enable port (output)
 *  \return None
 *
 **/
void t_wifi(chanend c_wifi_app,
            spi_master_interface &spi_if,
            out port p_wifi_pwr_en);

#endif // _wifi_spi_h_
/*==========================================================================*/
