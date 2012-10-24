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
#include "socket.h"
#include "hci.h"
#include "hci_helper.h"
#include "wifi_conf_defines.h"
#include "event_handler.h"
#include <print.h>

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/
//Enable this flag if and only if you must comply with BSD socket close() function
#ifdef _API_USE_BSD_CLOSE
   #define close(sd) closesocket(sd)
#endif

//Enable this flag if and only if you must comply with BSD socket read() and write() functions
#ifdef _API_USE_BSD_READ_WRITE
              #define read(sd, buf, len, flags) recv(sd, buf, len, flags)
              #define write(sd, buf, len, flags) send(sd, buf, len, flags)
#endif

#define SOCKET_OPEN_PARAMS_LEN              (12)
#define SOCKET_CLOSE_PARAMS_LEN             (4)
#define SOCKET_ACCEPT_PARAMS_LEN            (4)
#define SOCKET_BIND_PARAMS_LEN              (20)
#define SOCKET_LISTEN_PARAMS_LEN            (8)
#define SOCKET_GET_HOST_BY_NAME_PARAMS_LEN  (9)
#define SOCKET_CONNECT_PARAMS_LEN           (20)
#define SOCKET_SELECT_PARAMS_LEN            (44)
#define SOCKET_SET_SOCK_OPT_PARAMS_LEN      (20)
#define SOCKET_GET_SOCK_OPT_PARAMS_LEN      (12)
#define SOCKET_RECV_FROM_PARAMS_LEN         (12)
#define SOCKET_SENDTO_PARAMS_LEN            (24)

// The legnth of arguments for the SEND command: sd + buff_offset + len + flags, while size of each parameter
// is 32 bit - so the total length is 16 bytes;
#define HCI_CMND_SEND_ARG_LENGTH            (16)
#define SELECT_TIMEOUT_MIN_MICRO_SECONDS    5000
#define HEADERS_SIZE_DATA                   (SPI_HEADER_SIZE + 5)

#define SIMPLE_LINK_HCI_CMND_TRANSPORT_HEADER_SIZE  (SPI_HEADER_SIZE + SIMPLE_LINK_HCI_CMND_HEADER_SIZE)

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
static int simple_link_recv(chanend c_wifi,
                            int sd,
                            unsigned char buf[],
                            int len,
                            int flags,
                            skt_addr_t &from,
                            skt_len_t &from_len,
                            int opcode);

static int simple_link_send(chanend c_wifi,
                            int sd,
                            char data_buf[],
                            int len,
                            int flags,
                            skt_addr_t &to,
                            int tolen,
                            int opcode);

static int host_flowcontrol_consume_buff(int sd);

//*****************************************************************************
//
//! int useBuff(buff_mngr_flag_t blocked)
//!
//!  \param  blocked - BUFF_MNGR_BLOCK or BUFF_MNGR_NOBLOCK
//!
//!  \return current number of free buffers, or EFAIL,
//!          if no free buffers present
//!
//!  \brief  if blocked is BUFF_MNGR_BLOCK - block until have free pages,
//!          else return EFAIL and set errno to EAGAIN
//
//*****************************************************************************
static int host_flowcontrol_consume_buff(int sd)
{
    return 0;
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void skt_create(chanend c_wifi, int &my_skt, int domain, int type, int protocol)
{
    my_skt = EFAIL;

    // 32 bit to char
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 0), domain);
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 4), type);
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 8), protocol);

    // fill wlan_tx_buf and send command
    pkg_cmd(c_wifi,
            wlan_tx_buf,
            HCI_CMND_SOCKET,
            SOCKET_OPEN_PARAMS_LEN);

    // get result
    // vinith - see type
    c_wifi :> my_skt;
    set_socket_active_status(my_skt, SOCKET_STATUS_ACTIVE);
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void skt_close(chanend c_wifi, int sd)
{
    // 32 bit to char
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 0), sd);

    // fill wlan_tx_buf and send command
    pkg_cmd(c_wifi,
            wlan_tx_buf,
            HCI_CMND_CLOSE_SOCKET,
            SOCKET_CLOSE_PARAMS_LEN);

    // get result
    c_wifi :> int _;

    set_socket_active_status(sd, SOCKET_STATUS_INACTIVE);
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
int skt_accept(chanend c_wifi, int sd, skt_addr_t &addr)
{
    int ret;
    bsd_rtn_params_t rtn_args;

    ret = EFAIL;

    // 32 bit to char
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 0), sd);

    // fill wlan_tx_buf and send command
    pkg_cmd(c_wifi,
            wlan_tx_buf,
            HCI_CMND_ACCEPT,
            SOCKET_ACCEPT_PARAMS_LEN);

    // get result
    c_wifi :> rtn_args;

    ret = rtn_args.status;


    //if succeeded, iStatus = new socket descriptor. otherwise - error number (negative value ?)
    if(M_IS_VALID_SD(ret))
    {
        set_socket_active_status(sd, SOCKET_STATUS_ACTIVE);
    }
    else
    {
        set_socket_active_status(sd, SOCKET_STATUS_INACTIVE);
    }

    return ret;
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void skt_bind(chanend c_wifi, int sd, skt_addr_t &addr, int addr_len)
{
    addr_len = ASIC_ADDR_LEN;

    // 32 bit to char
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 0), sd);
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 4), 0x00000008);
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 8), addr_len);
    short_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 12), addr.sa_family);
    array_to_stream(wlan_tx_buf, addr.sa_data, (HEADERS_SIZE_CMD + 14), (addr_len - sizeof(addr.sa_family)));

    // fill wlan_tx_buf and send command
    pkg_cmd(c_wifi,
            wlan_tx_buf,
            HCI_CMND_BIND,
            SOCKET_BIND_PARAMS_LEN);

    // get result
    c_wifi :> int _;
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void skt_listen(chanend c_wifi, int sd, int backlog)
{
    // 32 bit to char
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 0), sd);
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 4), backlog);

    // fill wlan_tx_buf and send command
    pkg_cmd(c_wifi,
            wlan_tx_buf,
            HCI_CMND_LISTEN,
            SOCKET_BIND_PARAMS_LEN);

    // get result
    c_wifi :> int _;
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void skt_connect(chanend c_wifi,
                 int sd,
                 skt_addr_t &addr,
                 int addr_len)
{
    unsigned int index = SIMPLE_LINK_HCI_CMND_TRANSPORT_HEADER_SIZE;

    // 32 bit to char
    int_to_stream(wlan_tx_buf, (index + 0), sd);
    int_to_stream(wlan_tx_buf, (index + 4), 0x00000008);
    int_to_stream(wlan_tx_buf, (index + 8), addr_len);

    short_to_stream(wlan_tx_buf, (index + 12), addr.sa_family);
    array_to_stream(wlan_tx_buf, addr.sa_data, (index + 14), (addr_len - sizeof(addr.sa_family)));

    // fill wlan_tx_buf and send command
    pkg_cmd(c_wifi,
            wlan_tx_buf,
            HCI_CMND_CONNECT,
            SOCKET_CONNECT_PARAMS_LEN);

    // get result
    c_wifi :> int _;
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
#if 0
void skt_select(chanend c_wifi,
                int nfds,
                fd_set *readsds,
                fd_set *writesds,
                fd_set *exceptsds,
                struct timeval *timeout)
{
}
#endif


/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void skt_set_skt_opt(chanend c_wifi,
                     int sd,
                     int level,
                     int optname,
                     unsigned char optval[],
                     skt_len_t optlen)
{
    // 32 bit to char
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 0), sd);
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 4), level);
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 8), optname);
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 12), 0x00000008);
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 16), optlen);
    array_to_stream(wlan_tx_buf, optval, (HEADERS_SIZE_CMD + 20), optlen);

    // fill wlan_tx_buf and send command
    pkg_cmd(c_wifi,
            wlan_tx_buf,
            HCI_CMND_SETSOCKOPT,
            (SOCKET_SET_SOCK_OPT_PARAMS_LEN  + optlen));

    // get result
    c_wifi :> int _;
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void skt_get_skt_opt(chanend c_wifi,
                     int sd,
                     int level,
                     int opt_name,
                     unsigned char optval[],
                     skt_len_t &opt_len)
{
    bsd_get_skt_opt_rtn_params_t ret;

    // 32 bit to char
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 0), sd);
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 4), level);
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 8), opt_name);

    // fill wlan_tx_buf and send command
    pkg_cmd(c_wifi,
            wlan_tx_buf,
            HCI_CMND_GETSOCKOPT,
            SOCKET_GET_SOCK_OPT_PARAMS_LEN);

    // get result
    c_wifi :> ret;

    if(((signed char)ret.status) >= 0)
    {
        optval[0] = ret.opt_value[0];
        optval[1] = ret.opt_value[1];
        optval[2] = ret.opt_value[2];
        optval[3] = ret.opt_value[3];
        opt_len = 4;
    }
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
int skt_recv(chanend c_wifi,
              int sd,
              unsigned char buf[],
              int len,
              int flags)
{
    int num_bytes;
    skt_addr_t from;
    skt_len_t from_len;

    num_bytes = simple_link_recv(c_wifi, sd, buf, len, flags, from, from_len, HCI_CMND_RECV);
    return num_bytes;
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void skt_recv_from(chanend c_wifi,
                   int sd,
                   unsigned char data_buf[],
                   int len,
                   int flags,
                   skt_addr_t &from,
                   skt_len_t &from_len)
{
    int num_bytes;
    num_bytes = simple_link_recv(c_wifi, sd, data_buf, len, flags, from, from_len, HCI_CMND_RECVFROM);
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void skt_send(chanend c_wifi,
              int sd,
              char data_buf[],
              int len,
              int flags)
{
    int num_bytes;
    skt_addr_t to;
    skt_len_t tolen;
    num_bytes = simple_link_send(c_wifi, sd, data_buf, len, flags, to, tolen, HCI_CMND_SEND);
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void skt_send_to(chanend c_wifi,
                 int sd,
                 char data_buf[],
                 int len,
                 int flags,
                 skt_addr_t &to,
                 skt_len_t tolen)
{
    int num_bytes;
    num_bytes = simple_link_send(c_wifi, sd, data_buf, len, flags, to, tolen, HCI_CMND_SENDTO);
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void skt_get_host_by_name(chanend c_wifi,
                          char hostname[],
                          unsigned short name_len,
                          unsigned int &out_ip_addr)
{
    int index;
    bsd_get_host_by_name_params_t ret;

    if (name_len > HOSTNAME_MAX_LENGTH)
    {
        return;
    }

    index = SIMPLE_LINK_HCI_CMND_TRANSPORT_HEADER_SIZE;

    // 32 bit to char
    int_to_stream(wlan_tx_buf, (index + 0), 8);
    int_to_stream(wlan_tx_buf, (index + 4), name_len);
    array_to_stream(wlan_tx_buf, hostname, (index + 8), name_len);

    // fill wlan_tx_buf and send command
    pkg_cmd(c_wifi,
            wlan_tx_buf,
            HCI_CMND_GETHOSTNAME,
            (SOCKET_GET_HOST_BY_NAME_PARAMS_LEN + name_len - 1));

    // get result
    c_wifi :> ret;

    // update IP address
    out_ip_addr = ret.op_address;
}


//*****************************************************************************
//
//!  Read data from socket
//!
//!  @param sd       socket handle
//!  @param buf      read buffer
//!  @param len      buffer length
//!  @param flags    indicates blocking or non-blocking operation
//!  @param from     pointer to an address structure indicating source address
//!  @param fromlen  source address strcutre size
//!
//!  @return         Return the number of bytes received, or -1 if an error
//!                  occurred
//!
//!  @brief          Return the length of the message on successful completion.
//!                  If a message is too int to fit in the supplied buffer,
//!                  excess bytes may be discarded depending on the type of
//!                  socket the message is received from
//
//*****************************************************************************
static int simple_link_recv(chanend c_wifi,
                            int sd,
                            unsigned char data_buf[],
                            int len,
                            int flags,
                            skt_addr_t &from,
                            skt_len_t &from_len,
                            int opcode)
{
    int num_bytes;

    // 32 bit to char
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 0), sd);
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 4), len);
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 8), flags);

    // fill wlan_tx_buf and send command
    pkg_cmd(c_wifi,
            wlan_tx_buf,
            opcode,
            SOCKET_RECV_FROM_PARAMS_LEN);

    // get result
    c_wifi :> num_bytes;

    for(int i = 0; i < num_bytes; i++)
    {
        c_wifi :> data_buf[i];
    }

    return num_bytes;
}

//*****************************************************************************
//
//!  Send data to ASIC
//!
//!  @param sd       socket handle
//!  @param buf      write buffer
//!  @param len      buffer length
//!  @param flags    indicates blocking or non-blocking operation
//!  @param to       pointer to an address structure indicating destination
//!                  address
//!  @param tolen    destination address strcutre size
//!
//!  @return         Return the number of bytes transmited, or -1 if an error
//!                  occurred
//!
//!  @brief          This function is used to transmit a message to another
//!                  socket
//
//*****************************************************************************
static int simple_link_send(chanend c_wifi,
                            int sd,
                            char data_buf[],
                            int len,
                            int flags,
                            skt_addr_t &to,
                            int tolen,
                            int opcode)
{
    int index;
    int data_index;
    unsigned int addr_offset;
    unsigned char arg_size, addr_len;

    //sl_info.num_sent_pkts++;
    index = HEADERS_SIZE_DATA;

    // Update the offset of data and parameters according to the command
    switch(opcode)
    {
        case HCI_CMND_SENDTO:
        {
            addr_offset = len + sizeof(len) + sizeof(len);
            addr_len = 8;
            arg_size = SOCKET_SENDTO_PARAMS_LEN;
            data_index = HEADERS_SIZE_DATA + SOCKET_SENDTO_PARAMS_LEN;
            break;
        }

        case HCI_CMND_SEND:
        {
            tolen = 0;
            //to = NULL;
            arg_size = HCI_CMND_SEND_ARG_LENGTH;
            data_index = HEADERS_SIZE_DATA + HCI_CMND_SEND_ARG_LENGTH;
            break;
        }

        default:
        {
            break;
        }
    }

    // Fill in temporary command buffer
    int_to_stream(wlan_tx_buf, (index + 0), sd);
    int_to_stream(wlan_tx_buf, (index + 4), (arg_size - sizeof(sd)));
    int_to_stream(wlan_tx_buf, (index + 8), len);
    int_to_stream(wlan_tx_buf, (index + 12), flags);

    if (opcode == HCI_CMND_SENDTO)
    {
        int_to_stream(wlan_tx_buf, (index + 16), addr_offset);
        int_to_stream(wlan_tx_buf, (index + 20), addr_len);
    }

    // Copy the data received from user into the TX Buffer
    array_to_stream(wlan_tx_buf, data_buf, data_index, len);

    // In case we are using SendTo, copy the to parameters
    if (opcode == HCI_CMND_SENDTO)
    {
        index = data_index + len;
        short_to_stream(wlan_tx_buf, index, to.sa_family);
        array_to_stream(wlan_tx_buf, to.sa_data, (index + 2), (tolen - 2));
    }

    // Initiate a HCI command
    pkg_data(c_wifi,
             wlan_tx_buf,
             opcode,
             arg_size,
             len,
             tolen);

    //c_wifi :> int _;

    return len;
}

/*==========================================================================*/
