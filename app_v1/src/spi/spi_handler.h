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

#ifndef _spi_handler_h_
#define _spi_handler_h_

/*---------------------------------------------------------------------------
 nested include files
 ---------------------------------------------------------------------------*/
#include <xccompat.h>
#include "spi_tiwisl.h"

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
extern unsigned char wlan_tx_buffer[];

/*---------------------------------------------------------------------------
 prototypes
 ---------------------------------------------------------------------------*/

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
void spih_open();

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
void spih_close();

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
void spih_write(REFERENCE_PARAM(unsigned char, user_buffer),
                unsigned short num_bytes);

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
void spih_irq_handler();

#endif // _spi_handler_h_
/*==========================================================================*/
