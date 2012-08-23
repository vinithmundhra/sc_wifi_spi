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

#ifndef _spi_master_tiwisl_h_
#define _spi_master_tiwisl_h_

/*---------------------------------------------------------------------------
 nested include files
 ---------------------------------------------------------------------------*/
#include <xs1.h>

#ifdef __spi_conf_h_exists__
#include "spi_conf.h"
#endif

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/
#ifndef DEFAULT_SPI_CLOCK_DIV
#define DEFAULT_SPI_CLOCK_DIV 4
#endif

#ifndef SPI_MASTER_MODE
#define SPI_MASTER_MODE 0
#endif

/*---------------------------------------------------------------------------
 typedefs
 ---------------------------------------------------------------------------*/
/** Structure containing the resources required for the SPI master interface.
 *
 * It consists of two 8bit buffered output ports, and one 8bit input port.
 *
 * Select lines are intentionally not part of API, they are simple port outputs,
 * which depend on how many slaves there are and how they're connected.
 *
 */
typedef struct spi_master_interface
{
    clock clk_blk1;
    clock clk_blk2;
    out buffered port:8 p_mosi;
    out buffered port:8 p_sclk;
    in buffered port:8 p_miso;
    out port p_spi_cs;
    in port p_spi_irq;
} spi_master_interface;

/*---------------------------------------------------------------------------
 global variables
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 extern variables
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 prototypes
 ---------------------------------------------------------------------------*/

/** Configure ports and clocks, clearing port buffers.
 *
 * Must be called before any SPI data input or output functions are used.
 *
 * \param spi_if         Resources for the SPI interface being initialised
 * \param spi_clock_div  SPI clock frequency is fref/(2*spi_clock_div),
 *                       where freq defaults to 100MHz
 *
 * \note  Example: To achieve an sclk frequency of 25MHz, a divider of
 *        2 must be specified, as 100(MHz)/(2*2) = 25(MHz).
 * \note  Example: To achieve an sclk frequency of 625kHz, a divider of
 *        80 must be specified, as 100(MHz)/(2*80) = 0.625(MHz).
 *
 */
void spi_master_init(spi_master_interface &spi_if, int spi_clock_div);

/** Stops the clocks running.
 *
 * Should be called when all SPI input and output is completed.
 *
 * \param spi_if  Resources for the SPI interface being shutdown
 *
 */
void spi_master_shutdown(spi_master_interface &spi_if);

/** Receive specified number of bytes.
 *
 * Most significant bit first order.
 * Big endian byte order.
 *
 * \param spi_if     Resources for the SPI interface
 * \param buffer     The array the received data will be written to
 *
 */
void spi_master_read(spi_master_interface &spi_if, unsigned char buffer[]);

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
void spi_master_write(spi_master_interface &spi_if, unsigned char buffer[], int num_bytes);

#endif // _spi_master_tiwisl_h_
/*==========================================================================*/
