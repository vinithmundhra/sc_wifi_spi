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

#ifndef _spi_conf_h_
#define _spi_conf_h_

/*---------------------------------------------------------------------------
 nested include files
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/
/*
 * SPI clock frequency = (100 MHz)/(2 * DEFAULT_SPI_CLOCK_DIV)
 *                     = (100 MHz)/(2 * 4)
 *                     = 12.5 MHz
 * */
#define DEFAULT_SPI_CLOCK_DIV 4

/*
 * SPI Master Mode = 1
 * CPHA 1; CPOL 0
 */
#define SPI_MASTER_MODE 1

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

#endif // _spi_conf_h_

/*==========================================================================*/
