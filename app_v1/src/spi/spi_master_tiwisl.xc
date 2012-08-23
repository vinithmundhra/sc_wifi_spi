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
#include <xclib.h>
#include <print.h>
#include "spi_master_tiwisl.h"

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/

#define INDEX_SPI_HEADER_OPCODE     0
#define INDEX_SPI_HEADER_PLMSB      1
#define INDEX_SPI_HEADER_PLLSB      2
#define INDEX_SPI_HEADER_BUSY1      3
#define INDEX_SPI_HEADER_BUSY2      4
#define SIZE_SPI_HEADER             5

#define DELAY_FIRST_WRITE           5000 // 50us delay for first write

#define SPI_READ    0x03
#define SPI_WRITE   0x01

#define HI(value)   (((value) & 0xFF00) >> 8)
#define LO(value)   ((value) & 0x00FF)

/*---------------------------------------------------------------------------
 ports and clocks
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 typedefs
 ---------------------------------------------------------------------------*/
typedef struct spi_hdr
{
    unsigned char   cmd;
    unsigned short  length;
    unsigned char   pad[2];
}spi_hdr_t;

/*---------------------------------------------------------------------------
 global variables
 ---------------------------------------------------------------------------*/
unsigned sclk_val;

/*---------------------------------------------------------------------------
 static variables
 ---------------------------------------------------------------------------*/
static char first_write = 1;
//static unsigned char spi_read_hdr[SIZE_SPI_HEADER] = {SPI_READ, 0, 0, 0, 0};

/*---------------------------------------------------------------------------
 static prototypes
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 spi_master_in_byte_internal
 ---------------------------------------------------------------------------*/
static unsigned char spi_master_in_byte_internal(spi_master_interface &spi_if)
{
    // MSb-first bit order - SPI standard
    unsigned x;
    clearbuf(spi_if.p_miso);
    spi_if.p_sclk <: sclk_val;
    spi_if.p_sclk <: sclk_val;
    sync(spi_if.p_sclk);
    spi_if.p_miso :> x;
    return bitrev(x) >> 24;
}

/*---------------------------------------------------------------------------
 spi_master_out_byte_internal
 ---------------------------------------------------------------------------*/
static void spi_master_out_byte_internal(spi_master_interface &spi_if,
                                         unsigned char data)
{
    // MSb-first bit order - SPI standard
    unsigned x = bitrev(data) >> 24;

#if (SPI_MASTER_MODE == 0 || SPI_MASTER_MODE == 2) // modes where CPHA == 0
    // handle first bit
    asm("setc res[%0], 8" :: "r"(spi_if.p_mosi)); // reset port
    spi_if.p_mosi <: x; // output first bit
    asm("setc res[%0], 8" :: "r"(spi_if.p_mosi)); // reset port
    asm("setc res[%0], 0x200f" :: "r"(spi_if.p_mosi)); // set to buffering
    asm("settw res[%0], %1" :: "r"(spi_if.p_mosi), "r"(32)); // set transfer width to 32
    stop_clock(spi_if.clk_blk2);
    configure_clock_src(spi_if.clk_blk2, spi_if.p_sclk);
    configure_out_port(spi_if.p_mosi, spi_if.clk_blk2, x);
    start_clock(spi_if.clk_blk2);

    // output remaining data
    spi_if.p_mosi <: (x >> 1);
#else
    spi_if.p_mosi <: x;
#endif
    spi_if.p_sclk <: sclk_val;
    spi_if.p_sclk <: sclk_val;
    sync(spi_if.p_sclk);
    spi_if.p_miso :> void;
}

/*---------------------------------------------------------------------------
 spi_master_first_write
 ---------------------------------------------------------------------------*/
static void spi_master_first_write(spi_master_interface &spi_if,
                                   unsigned char buffer[],
                                   int num_bytes)
{
    timer t;
    unsigned time;

    // wait for IRQ to be low
    spi_if.p_spi_irq when pinseq(0) :> void;

    // Assert nCS
    spi_if.p_spi_cs <: 0;

    // Delay 50us
    t :> time;
    time += DELAY_FIRST_WRITE;
    t when timerafter(time) :> void;

    // Transmit first 4 bytes
    for (int i = 0; i < 4; i++)
    {
        spi_master_out_byte_internal(spi_if, buffer[i]);
    }

    // Delay 50us
    time += DELAY_FIRST_WRITE;
    t when timerafter(time) :> void;

    // Transmit rest of the bytes
    for (int i = 4; i < num_bytes; i++)
    {
        spi_master_out_byte_internal(spi_if, buffer[i]);
    }

    // wait for IRQ to be high
    spi_if.p_spi_irq when pinseq(1) :> void;

    // Deassert nCS
    spi_if.p_spi_cs <: 1;

    first_write = 0;
}

/*---------------------------------------------------------------------------
 spi_master_init
 ---------------------------------------------------------------------------*/
void spi_master_init(spi_master_interface &spi_if, int spi_clock_div)
{
    // configure ports and clock blocks
    configure_clock_rate(spi_if.clk_blk1, 100, spi_clock_div);
#if SPI_MASTER_MODE == 0
    set_port_no_inv(spi_if.p_sclk);
    configure_out_port(spi_if.p_sclk, spi_if.clk_blk1, 0);
    sclk_val = 0x55;
#elif SPI_MASTER_MODE == 1
    set_port_inv(spi_if.p_sclk); // invert port and values used
    configure_out_port(spi_if.p_sclk, spi_if.clk_blk1, 1);
    sclk_val = 0xAA;
#elif SPI_MASTER_MODE == 2
    set_port_inv(spi_if.p_sclk); // invert port and values used
    configure_out_port(spi_if.p_sclk, spi_if.clk_blk1, 0);
    sclk_val = 0x55;
#elif SPI_MASTER_MODE == 3
    set_port_no_inv(spi_if.p_sclk);
    configure_out_port(spi_if.p_sclk, spi_if.clk_blk1, 1);
    sclk_val = 0xAA;
#else
#error "Unrecognised SPI mode."
#endif
    configure_clock_src(spi_if.clk_blk2, spi_if.p_sclk);
    configure_out_port(spi_if.p_mosi, spi_if.clk_blk2, 0);
    configure_in_port(spi_if.p_miso, spi_if.clk_blk2);
    clearbuf(spi_if.p_mosi);
    clearbuf(spi_if.p_sclk);
    start_clock(spi_if.clk_blk1);
    start_clock(spi_if.clk_blk2);
}

/*---------------------------------------------------------------------------
 spi_master_shutdown
 ---------------------------------------------------------------------------*/
void spi_master_shutdown(spi_master_interface &spi_if)
{
    // need clock ticks in order to stop clock blocks
    spi_if.p_sclk <: sclk_val;
    spi_if.p_sclk <: sclk_val;
    stop_clock(spi_if.clk_blk2);
    stop_clock(spi_if.clk_blk1);
}

/*---------------------------------------------------------------------------
 spi_master_read
 ---------------------------------------------------------------------------*/
void spi_master_read(spi_master_interface &spi_if,
                     unsigned char buffer[])
{
    unsigned short rx_length;
    unsigned char mychar;

    // Confirm IRQ to be low
    spi_if.p_spi_irq when pinseq(0) :> void;

    // Assert CS
    spi_if.p_spi_cs <: 0;

    // Read bytes indicating length that follows
    rx_length = ((short)(spi_master_in_byte_internal(spi_if)) << 8);
    rx_length += (short)(spi_master_in_byte_internal(spi_if));

    printstr("read size = "); printintln(rx_length);

    // Read the data from device
    for (int i = 0; i < rx_length; i++)
    {
        mychar = spi_master_in_byte_internal(spi_if);
        printintln(mychar);
    }

    // Deassert nCS
    spi_if.p_spi_cs <: 1;

    // wait for IRQ to be high
    spi_if.p_spi_irq when pinseq(1) :> void;
}

/*---------------------------------------------------------------------------
 spi_master_write
 ---------------------------------------------------------------------------*/
void spi_master_write(spi_master_interface &spi_if,
                      unsigned char buffer[],
                      int num_bytes)
{
    if(first_write == 1)
    {
        spi_master_first_write(spi_if, buffer, num_bytes);

    } // if(first_write == 1)
    else
    {
        // Assert nCS
        spi_if.p_spi_cs <: 0;

        // wait for IRQ to be low
        spi_if.p_spi_irq when pinseq(0) :> void;

        for (int i = 0; i < num_bytes; i++)
        {
            spi_master_out_byte_internal(spi_if, buffer[i]);
        }

        // Deassert nCS
        spi_if.p_spi_cs <: 1;

        // wait for IRQ to be high
        spi_if.p_spi_irq when pinseq(1) :> void;

    } // else - if(first_write == 1)
}

/*==========================================================================*/
