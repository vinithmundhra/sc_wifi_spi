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
#include "hci.h"
#include "wifi_conf_defines.h"

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/
#define WRITE               1
#define HI(value)           (((value) & 0xFF00) >> 8)
#define LO(value)           ((value) & 0x00FF)

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
static int pkg_spi(unsigned char buffer[], unsigned short length);
static void send_to_wm(chanend c_wifi, unsigned char buffer[], int length);

/*---------------------------------------------------------------------------
 pkg_cmd
 ---------------------------------------------------------------------------*/
void pkg_cmd(chanend c_wifi,
             unsigned char buffer[],
             unsigned short opcode,
             unsigned char length)
{
    int pkg_len;

    buffer[SPI_HEADER_SIZE]     = HCI_TYPE_CMND;
    buffer[SPI_HEADER_SIZE + 1] = LO(opcode);
    buffer[SPI_HEADER_SIZE + 2] = HI(opcode);
    buffer[SPI_HEADER_SIZE + 3] = length;

    pkg_len = pkg_spi(buffer, SIMPLE_LINK_HCI_CMND_HEADER_SIZE + length);

    send_to_wm(c_wifi, buffer, pkg_len);
}

/*---------------------------------------------------------------------------
 pkg_data
 ---------------------------------------------------------------------------*/
void pkg_data(chanend c_wifi,
              unsigned char buffer[],
              unsigned char opcode,
              unsigned short arg_length,
              unsigned short data_length,
              unsigned short tail_length)
{
    int pkg_len;
    pkg_len = arg_length + data_length + tail_length;

    buffer[SPI_HEADER_SIZE]     = HCI_TYPE_DATA;
    buffer[SPI_HEADER_SIZE + 1] = opcode;
    buffer[SPI_HEADER_SIZE + 2] = arg_length;
    buffer[SPI_HEADER_SIZE + 3] = LO(pkg_len);
    buffer[SPI_HEADER_SIZE + 4] = HI(pkg_len);

    pkg_len = pkg_spi(buffer, SIMPLE_LINK_HCI_DATA_HEADER_SIZE + pkg_len);

    send_to_wm(c_wifi, buffer, pkg_len);
}

/*---------------------------------------------------------------------------
 pkg_data_cmd
 ---------------------------------------------------------------------------*/
void pkg_data_cmd(chanend c_wifi,
                  unsigned char buffer[],
                  unsigned char opcode,
                  unsigned short arg_length,
                  unsigned short data_length)
{
    int pkg_len;
    pkg_len = arg_length + data_length;

    buffer[SPI_HEADER_SIZE]     = HCI_TYPE_DATA;
    buffer[SPI_HEADER_SIZE + 1] = opcode;
    buffer[SPI_HEADER_SIZE + 2] = arg_length;
    buffer[SPI_HEADER_SIZE + 3] = LO(pkg_len);
    buffer[SPI_HEADER_SIZE + 4] = HI(pkg_len);

    pkg_len = pkg_spi(buffer, SIMPLE_LINK_HCI_DATA_CMND_HEADER_SIZE + pkg_len);

    send_to_wm(c_wifi, buffer, pkg_len);
}

/*---------------------------------------------------------------------------
 send_to_wm
 ---------------------------------------------------------------------------*/
static void send_to_wm(chanend c_wifi, unsigned char buffer[], int length)
{
    c_wifi <: length;
    for(int i = 0; i < length; i++) { c_wifi <: buffer[i]; }
}

/*---------------------------------------------------------------------------
 pkg_spi
 ---------------------------------------------------------------------------*/
static int pkg_spi(unsigned char buffer[], unsigned short length)
{
    int pad = 0;

    if(!(length & 0x0001))
    {
        pad++;
        buffer[SPI_HEADER_SIZE + length] = 0;
    }

    buffer[0] = WRITE;
    buffer[1] = HI(length + pad);
    buffer[2] = LO(length + pad);
    buffer[3] = 0;
    buffer[4] = 0;

    return (SPI_HEADER_SIZE + length + pad);
}

/*==========================================================================*/
