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

#ifndef _spi_tiwisl_h_
#define _spi_tiwisl_h_

/*---------------------------------------------------------------------------
 nested include files
 ---------------------------------------------------------------------------*/
#include "spi_master.h"

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 typedefs
 ---------------------------------------------------------------------------*/
typedef struct spi_tiwisl_ctrl_t_
{
    out port p_spi_cs;
    in port p_spi_irq;
    out port p_pwr_en;
} spi_tiwisl_ctrl_t;

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
 *  Initialize SPI ports, enable wifi power, CS, IRQ and SPI master mode
 *
 *  \param spi_if           The SPI interface: MOSI, MISO, CLK
 *  \param spi_tiwisl_ctrl  Other i/f lines: nCS, nIRQ, PWR_ENABLE
 *
 **/
void spi_tiwisl_init(spi_master_interface &spi_if,
                     spi_tiwisl_ctrl_t &spi_tiwisl_ctrl);

/*==========================================================================*/
/**
 *  Stops SPI. Wifi power off.
 *
 *  \param spi_if           The SPI interface: MOSI, MISO, CLK
 *  \param spi_tiwisl_ctrl  Other i/f lines: nCS, nIRQ, PWR_ENABLE
 *
 **/
void spi_shutdown(spi_master_interface &spi_if,
                  spi_tiwisl_ctrl_t &spi_tiwisl_ctrl);

/*==========================================================================*/
/**
 *  Receive specified number of bytes on the SPI i/f.
 *  Most significant bit first order (Big endian byte order).
 *
 *  \param spi_if           The SPI interface: MOSI, MISO, CLK
 *  \param spi_tiwisl_ctrl  Other i/f lines: nCS, nIRQ, PWR_ENABLE
 *  \param buffer           The array the received data will be written to
 *  \param num_bytes        Number of bytes to receive
 *
 **/
void spi_read(spi_master_interface &spi_if, spi_tiwisl_ctrl_t &spi_tiwisl_ctrl,
              unsigned char buffer[], unsigned short num_bytes);

/*==========================================================================*/
/**
 *  SPI Write for the first time. This Write operation has 50 us time delays
 *  as specified (after asserting nCS and after the 4th byte sent).
 *
 *  \param spi_if           The SPI interface: MOSI, MISO, CLK
 *  \param spi_tiwisl_ctrl  Other i/f lines: nCS, nIRQ, PWR_ENABLE
 *  \param buffer           The array of data to transmit
 *  \param num_bytes        Number of bytes to transmit
 *
 **/
void spi_first_write(spi_master_interface &spi_if,
                     spi_tiwisl_ctrl_t &spi_tiwisl_ctrl,
                     unsigned char buffer[],
                     unsigned short num_bytes);

/*==========================================================================*/
/**
 *  Normal SPI Write. Transmit specified number of bytes.
 *
 *  \param spi_if           The SPI interface: MOSI, MISO, CLK
 *  \param spi_tiwisl_ctrl  Other i/f lines: nCS, nIRQ, PWR_ENABLE
 *  \param buffer           The array of data to transmit
 *  \param num_bytes        Number of bytes to transmit
 *
 **/
void spi_write(spi_master_interface &spi_if,
               spi_tiwisl_ctrl_t &spi_tiwisl_ctrl,
               unsigned char buffer[],
               unsigned short num_bytes);

#endif // _spi_master_tiwisl_h_
/*==========================================================================*/
