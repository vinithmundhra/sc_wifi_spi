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
#include "spi_tiwisl.h"
#include "spi_master.h"

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/
#define DELAY_FIRST_WRITE   5000 // 50us delay for first write
#define READ                3

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
unsigned char spi_read_header[] = {READ, 0, 0, 0, 0};

/*---------------------------------------------------------------------------
 static prototypes
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 spi_init
 ---------------------------------------------------------------------------*/
void spi_tiwisl_init(spi_master_interface &spi_if,
                     spi_tiwisl_ctrl_t &spi_tiwisl_ctrl)
{
    unsigned irq_val;

    // Read the interrupt pin
    spi_tiwisl_ctrl.p_spi_irq :> irq_val;

    // Enable Wi-Fi power
    spi_tiwisl_ctrl.p_pwr_en <: 1;

    if(irq_val)
    {
        // Wait for IRQ to be low
        spi_tiwisl_ctrl.p_spi_irq when pinseq(0) :> void;
    }
    else
    {
        // Wait for IRQ to be High and then low
        spi_tiwisl_ctrl.p_spi_irq when pinseq(1) :> void;
        spi_tiwisl_ctrl.p_spi_irq when pinseq(0) :> void;
    }

    // Init SPI
    spi_master_init(spi_if, DEFAULT_SPI_CLOCK_DIV);
}

/*---------------------------------------------------------------------------
 spi_shutdown
 ---------------------------------------------------------------------------*/
void spi_shutdown(spi_master_interface &spi_if,
                  spi_tiwisl_ctrl_t &spi_tiwisl_ctrl)
{
    // Disable Wi-Fi power
    spi_tiwisl_ctrl.p_pwr_en <: 0;

    // Init SPI
    spi_master_shutdown(spi_if);
}

/*---------------------------------------------------------------------------
 spi_master_read
 ---------------------------------------------------------------------------*/
void spi_read(spi_master_interface &spi_if,
              spi_tiwisl_ctrl_t &spi_tiwisl_ctrl,
              unsigned char buffer[],
              unsigned short num_bytes)
{
    // Wait for IRQ to be low
    spi_tiwisl_ctrl.p_spi_irq when pinseq(0) :> void;

    // Assert CS
    spi_tiwisl_ctrl.p_spi_cs <: 0;

    // Issue the read command
    spi_master_out_buffer(spi_if, spi_read_header, 3);

    // Read the SPI data from device
    spi_master_in_buffer(spi_if, buffer, num_bytes);

    // Deassert nCS
    spi_tiwisl_ctrl.p_spi_cs <: 1;

    // wait for IRQ to be high
    //spi_tiwisl_ctrl.p_spi_irq when pinseq(1) :> void;
}

/*---------------------------------------------------------------------------
 spi_master_first_write
 ---------------------------------------------------------------------------*/
void spi_first_write(spi_master_interface &spi_if,
                     spi_tiwisl_ctrl_t &spi_tiwisl_ctrl,
                     unsigned char buffer[],
                     unsigned short num_bytes)
{
    timer t;
    unsigned time;

    // wait for IRQ to be low
    spi_tiwisl_ctrl.p_spi_irq when pinseq(0) :> void;

    // Assert nCS
    spi_tiwisl_ctrl.p_spi_cs <: 0;

    // Delay 50us
    t :> time;
    time += DELAY_FIRST_WRITE;
    t when timerafter(time) :> void;

    // Transmit first 4 bytes
    spi_master_out_buffer(spi_if, buffer, 4);

    // Delay 50us
    time += DELAY_FIRST_WRITE;
    t when timerafter(time) :> void;

    // Transmit rest of the bytes
    // TODO: transmit whole buffer instead of byte-by-byte loop
    for(int i = 4; i < num_bytes; i++)
    {
        spi_master_out_byte(spi_if, buffer[i]);
    }

    // Deassert nCS
    spi_tiwisl_ctrl.p_spi_cs <: 1;

    // wait for IRQ to be HI
    spi_tiwisl_ctrl.p_spi_irq when pinseq(1) :> void;
}

/*---------------------------------------------------------------------------
 spi_master_write
 ---------------------------------------------------------------------------*/
void spi_write(spi_master_interface &spi_if,
               spi_tiwisl_ctrl_t &spi_tiwisl_ctrl,
               unsigned char buffer[],
               unsigned short num_bytes)
{
    // Assert nCS
    spi_tiwisl_ctrl.p_spi_cs <: 0;

    // wait for IRQ to be low
    spi_tiwisl_ctrl.p_spi_irq when pinseq(0) :> void;

    // Transmit SPI bytes to device
    spi_master_out_buffer(spi_if, buffer, num_bytes);

    // Deassert nCS
    spi_tiwisl_ctrl.p_spi_cs <: 1;

    // wait for IRQ to be high
    spi_tiwisl_ctrl.p_spi_irq when pinseq(1) :> void;
}

/*==========================================================================*/
