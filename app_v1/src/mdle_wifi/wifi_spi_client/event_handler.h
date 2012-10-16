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

#ifndef _event_handler_h_
#define _event_handler_h_

/*---------------------------------------------------------------------------
 nested include files
 ---------------------------------------------------------------------------*/
#include "socket.h"

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/
#define SOCKET_STATUS_ACTIVE            (0)
#define SOCKET_STATUS_INACTIVE          (1)

/* Init socket_active_status = 'all ones': init all sockets with SOCKET_STATUS_INACTIVE.
   Will be changed by 'set_socket_active_status' upon 'connect' and 'accept' calls */
#define SOCKET_STATUS_INIT_VAL          0xFFFF

#define M_IS_VALID_SD(sd)               ((0 <= (sd)) && ((sd) <= 7))
#define M_IS_VALID_STATUS(status)       (((status) == SOCKET_STATUS_ACTIVE)||((status) == SOCKET_STATUS_INACTIVE))

#define BSD_RECV_FROM_FROMLEN_OFFSET    (4)
#define BSD_RECV_FROM_FROM_OFFSET       (16)

/*---------------------------------------------------------------------------
 typedefs
 ---------------------------------------------------------------------------*/
typedef struct bsd_rtn_params_t_
{
    int skt_descriptor;
    int status;
    skt_addr_t skt_address;

} bsd_rtn_params_t;

typedef struct bsd_read_rtn_params_t_
{
    int skt_descriptor;
    int num_bytes;
    unsigned int flags;
} bsd_read_rtn_params_t;

typedef struct bsd_select_rx_param_t_
{
    int          status;
    unsigned int rdfd;
    unsigned int wrfd;
    unsigned int exfd;
} bsd_select_rx_param_t;

typedef struct bsd_get_skt_opt_rtn_params_t_
{
    unsigned char opt_value[4];
    char          status;
} bsd_get_skt_opt_rtn_params_t;

typedef struct bsd_get_host_by_name_params_t_
{
    int rtnval;
    int op_address;
} bsd_get_host_by_name_params_t;

/*---------------------------------------------------------------------------
 global variables
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 extern variables
 ---------------------------------------------------------------------------*/
extern unsigned int socket_active_status;

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
int event_handler(chanend c_wifi, unsigned char buf[], unsigned short len);

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
int get_socket_active_status(int sd);

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
void set_socket_active_status(int sd, int status);

#endif // _event_handler_h_
/*==========================================================================*/
