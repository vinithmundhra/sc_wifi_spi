// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*===========================================================================
 Info
 ----
 
 ===========================================================================*/

#ifndef _hci_pkg_h_
#define _hci_pkg_h_

/*---------------------------------------------------------------------------
 nested include files
 ---------------------------------------------------------------------------*/
#include <xccompat.h>
#include "xtcp_client.h"

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/
#ifdef __XC__
#define NULLABLE ?
#else
#define NULLABLE
#endif

#define HCI_TYPE_CMND                                   0x1
#define HCI_TYPE_DATA                                   0x2
#define HCI_TYPE_PATCH                                  0x3
#define HCI_TYPE_EVNT                                   0x4

#define SPI_HEADER_SIZE                                 (5)
#define SIMPLE_LINK_HCI_CMND_HEADER_SIZE                (4)
#define HEADERS_SIZE_CMD                                (SPI_HEADER_SIZE + SIMPLE_LINK_HCI_CMND_HEADER_SIZE)
#define SIMPLE_LINK_HCI_DATA_HEADER_SIZE                (5)

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
int hci_pkg_wifi_on();
                         
/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
int hci_pkg_read_buffer_size();

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
int hci_pkg_set_event_mask(int mask);

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
int hci_pkg_wlan_connect(REFERENCE_PARAM(wifi_ap_config_t, ap_config));

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
int hci_pkg_wlan_set_connection_policy(unsigned int should_connect_to_open_ap,
                                       unsigned int should_use_fast_connect,
                                       unsigned int use_profiles);

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
int hci_pkg_skt_create(xtcp_protocol_t p);

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
int hci_pkg_skt_bind(int conn_id, int port_number);

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
int hci_pkg_skt_listen(int conn_id);

#endif // _hci_pkg_h_
/*==========================================================================*/
