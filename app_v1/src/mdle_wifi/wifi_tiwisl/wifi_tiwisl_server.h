// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*===========================================================================
 Info
 ----

 ===========================================================================*/

#ifndef _wifi_tiwisl_server_h_
#define _wifi_tiwisl_server_h_

/*---------------------------------------------------------------------------
 nested include files
 ---------------------------------------------------------------------------*/
#include "spi_master.h"
#include <xccompat.h>

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 typedefs
 ---------------------------------------------------------------------------*/
typedef struct wifi_tiwisl_ctrl_ports_t_
{
    out port p_spi_cs;
    in port p_spi_irq;
    out port p_pwr_en;
} wifi_tiwisl_ctrl_ports_t;

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
void wifi_tiwisl_server(chanend c_xtcp,
                        REFERENCE_PARAM(spi_master_interface, tiwisl_spi),
                        REFERENCE_PARAM(wifi_tiwisl_ctrl_ports_t, tiwisl_ctrl));

#endif // _wifi_tiwisl_server_h_
/*==========================================================================*/
