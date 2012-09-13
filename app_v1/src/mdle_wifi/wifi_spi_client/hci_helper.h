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

#ifndef _hci_helper_h_
#define _hci_helper_h_

/*---------------------------------------------------------------------------
 nested include files
 ---------------------------------------------------------------------------*/

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
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
void short_to_stream(unsigned char b[], unsigned short o, unsigned short v);

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
void int_to_stream(unsigned char b[], unsigned short o, unsigned int v);

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
unsigned short stream_to_short(unsigned char b[], unsigned short o);

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
unsigned int stream_to_int(unsigned char b[], unsigned short o);

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
void array_to_stream(unsigned char b[], char a[], unsigned short o, unsigned short l);

#endif // _hci_helper_h_
/*==========================================================================*/
