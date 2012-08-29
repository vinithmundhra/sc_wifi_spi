// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*****************************************************************************
 *
 *  hci.c  - CC3000 Host Driver Implementation.
 *  Copyright (C) 2011 Texas Instruments Incorporated - http://www.ti.com/
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *
 *    Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 *    Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the
 *    distribution.
 *
 *    Neither the name of Texas Instruments Incorporated nor the names of
 *    its contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 *  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 *  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 *  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 *  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 *  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 *  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 *  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 *  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 *  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 *****************************************************************************/

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
#include <string.h>
#include "hci.h"
#include "spi_handler.h"

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/
#define SL_PATCH_PORTION_SIZE       (1000)

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
 hci_command_send
 ---------------------------------------------------------------------------*/
unsigned short hci_command_send(unsigned short opcode,
                                unsigned char *user_buf,
                                unsigned char args_length)
{
    hci_cmnd_hdr_t *hci_cmnd_hdr_ptr;
    hci_cmnd_hdr_ptr = (hci_cmnd_hdr_t *) (user_buf + SPI_HEADER_SIZE);
    hci_cmnd_hdr_ptr->type = HCI_TYPE_CMND;
    hci_cmnd_hdr_ptr->opcode = opcode;
    hci_cmnd_hdr_ptr->length = args_length;

    // Update the opcode of the event we will be waiting for
    spih_write(user_buf, args_length + sizeof(hci_cmnd_hdr_t));
    return (0);
}

/*---------------------------------------------------------------------------
 hci_data_send
 ---------------------------------------------------------------------------*/
long hci_data_send(unsigned char opcode,
                   unsigned char *user_buf,
                   unsigned short args_length,
                   unsigned short data_length,
                   unsigned short tail_length)
{
    hci_data_hdr_t *hci_data_hdr_ptr;
    hci_data_hdr_ptr = (hci_data_hdr_t *) ((user_buf) + SPI_HEADER_SIZE);

    // Fill in the HCI header of data packet
    hci_data_hdr_ptr->type = HCI_TYPE_DATA;
    hci_data_hdr_ptr->opcode = opcode;
    hci_data_hdr_ptr->arg_size = args_length;
    hci_data_hdr_ptr->length = args_length + data_length + tail_length;

    // Send the packet over the SPI
    spih_write(user_buf, sizeof(hci_data_hdr_t) + args_length + data_length + tail_length);
    return (0);
}

/*---------------------------------------------------------------------------
 hci_data_command_send
 ---------------------------------------------------------------------------*/
void hci_data_command_send(unsigned short opcode,
                           unsigned char *user_buf,
                           unsigned char args_length,
                           unsigned short data_length)
{
    hci_data_cmd_hdr_t *hci_cmnd_hdr_ptr;
    hci_cmnd_hdr_ptr = (hci_data_cmd_hdr_t *) (user_buf + SPI_HEADER_SIZE);
    hci_cmnd_hdr_ptr->type = HCI_TYPE_DATA;
    hci_cmnd_hdr_ptr->opcode = opcode;
    hci_cmnd_hdr_ptr->arg_size = args_length;
    hci_cmnd_hdr_ptr->total_length = args_length + data_length;

    // Send command over SPI on data channel
    spih_write(user_buf, args_length + data_length + sizeof(hci_data_cmd_hdr_t));
}



/*
 * DUMMY - ignore for now
 */
void hci_patch_send(unsigned char ucOpcode,
                    unsigned char *pucBuff,
                    char *patch,
                    unsigned short usDataLength)
{
    // DUMMY - ignore for now
}
/*==========================================================================*/
