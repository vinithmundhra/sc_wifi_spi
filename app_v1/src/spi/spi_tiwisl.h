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

 SPI modes:
 +------+------+------+-----------+
 | Mode | CPOL | CPHA | Supported |
 +------+------+------+-----------+
 |   0  |   0  |   0  |    Yes    |
 |   1  |   0  |   1  |    Yes    |
 |   2  |   1  |   0  |    Yes    |
 |   3  |   1  |   1  |    Yes    |
 +------+------+------+-----------+

 ===========================================================================*/

#ifndef _spi_tiwisl_h_
#define _spi_tiwisl_h_

/*---------------------------------------------------------------------------
 nested include files
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 typedefs
 ---------------------------------------------------------------------------*/
#ifdef __XC__
typedef struct spi_tiwisl_ctrl_t_
{
    out port p_spi_cs;
    in port p_spi_irq;
    out port p_pwr_en;
} spi_tiwisl_ctrl_t;
#endif

/*---------------------------------------------------------------------------
 global variables
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 extern variables
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 prototypes
 ---------------------------------------------------------------------------*/

/** Initialize SPI ports
 * Enable wifi power, CS, IRQ
 * Initialize SPI master mode
 */
void spi_init();

/** Stops SPI.
 * Wifi power off.
 */
void spi_shutdown();

/** Receive specified number of bytes.
 *
 * Most significant bit first order.
 * Big endian byte order.
 *
 * \param spi_if     Resources for the SPI interface
 * \param buffer     The array the received data will be written to
 *
 */
void spi_read(unsigned char buffer[], unsigned short num_bytes);

/** Transmit dummy for the first write transaction.
 *
 * Most significant bit first order.
 * Big endian byte order.
 *
 * \param spi_if     Resources for the SPI interface
 * \param buffer     The array of data to transmit
 * \param num_bytes  The number of bytes to write to the SPI interface,
 *                   this must not be greater than the size of buffer
 *
 */
void spi_first_write(unsigned char buffer[], unsigned short num_bytes);

/** Transmit specified number of bytes.
 *
 * Most significant bit first order.
 * Big endian byte order.
 *
 * \param spi_if     Resources for the SPI interface
 * \param buffer     The array of data to transmit
 * \param num_bytes  The number of bytes to write to the SPI interface,
 *                   this must not be greater than the size of buffer
 *
 */
void spi_write(unsigned char buffer[], unsigned short num_bytes);

#endif // _spi_master_tiwisl_h_
/*==========================================================================*/
