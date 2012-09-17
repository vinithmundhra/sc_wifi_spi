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
                            long sd,
                            unsigned char buf[],
                            long len,
                            long flags,
                            skt_addr_t &from,
                            skt_len_t &from_len,
                            long opcode);

static int simple_link_send(chanend c_wifi,
                            long sd,
                            char buf[],
                            long len,
                            long flags,
                            skt_addr_t &to,
                            long tolen,
                            long opcode);

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void skt_create(chanend c_wifi, long domain, long type, long protocol)
{
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
    c_wifi :> int _;

    // todo: set socket active status
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void skt_close(chanend c_wifi, long sd)
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

    // todo: set socket active status
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void skt_accept(chanend c_wifi, long sd, skt_addr_t &addr, skt_len_t &addrlen)
{
    // 32 bit to char
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 0), sd);

    // fill wlan_tx_buf and send command
    pkg_cmd(c_wifi,
            wlan_tx_buf,
            HCI_CMND_ACCEPT,
            SOCKET_ACCEPT_PARAMS_LEN);

    // get result
    c_wifi :> int _;

    // todo: set socket active status

    addrlen = ASIC_ADDR_LEN;

}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void skt_bind(chanend c_wifi, long sd, skt_addr_t &addr, long addr_len)
{
    addr_len = ASIC_ADDR_LEN;

    // 32 bit to char
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 0), sd);
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 4), 0x00000008);
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 8), addr_len);
    // array to stream
    // todo
    //array_to_stream(wlan_tx_buf, addr, (HEADERS_SIZE_CMD + 12), addr_len);

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
void skt_listen(chanend c_wifi, long sd, long backlog)
{
    // 32 bit to char
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 0), sd);
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 4), backlog);

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
void skt_connect(chanend c_wifi,
                 long sd,
                 skt_addr_t &addr,
                 long addr_len)
{
    unsigned int index = SIMPLE_LINK_HCI_CMND_TRANSPORT_HEADER_SIZE;

    // 32 bit to char
    int_to_stream(wlan_tx_buf, (index + 0), sd);
    int_to_stream(wlan_tx_buf, (index + 4), 0x00000008);
    int_to_stream(wlan_tx_buf, (index + 8), addr_len);
    // array to stream
    // todo
    //array_to_stream(wlan_tx_buf, addr, (index + 12), addr_len);

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
                long nfds,
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
                     long sd,
                     long level,
                     long optname,
                     unsigned char optval[],
                     skt_len_t optlen)
{
    // 32 bit to char
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 0), sd);
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 4), level);
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 8), optname);
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 12), 0x00000008);
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 16), optlen);
    // array to stream
    // todo
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
                     long sd,
                     long level,
                     long opt_name,
                     unsigned char optval[],
                     skt_len_t &opt_len)
{
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
    c_wifi :> int _;

    // todo: copy rx optval to this optval
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void skt_recv(chanend c_wifi,
              long sd,
              unsigned char buf[],
              long len,
              long flags)
{
    int num_bytes;
    //num_bytes = simple_link_recv(c_wifi, sd, buf, len, flags, 0, 0, HCI_CMND_RECV);
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void skt_recv_from(chanend c_wifi,
                   long sd,
                   unsigned char buf[],
                   long len,
                   long flags,
                   skt_addr_t &from,
                   skt_len_t &from_len)
{
    int num_bytes;
    num_bytes = simple_link_recv(c_wifi, sd, buf, len, flags, from, from_len, HCI_CMND_RECVFROM);
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void skt_send(chanend c_wifi,
              long sd,
              char buf[],
              long len,
              long flags)
{
    int num_bytes;
    //num_bytes = simple_link_send(c_wifi, sd, buf, len, flags, 0, 0, HCI_CMND_SEND);
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void skt_send_to(chanend c_wifi,
                 long sd,
                 char buf[],
                 long len,
                 long flags,
                 skt_addr_t &to,
                 skt_len_t tolen)
{
    int num_bytes;
    num_bytes = simple_link_send(c_wifi, sd, buf, len, flags, to, tolen, HCI_CMND_SENDTO);
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void skt_get_host_by_name(chanend c_wifi,
                          char hostname[],
                          unsigned short name_len,
                          unsigned long &out_ip_addr)
{
    int index;

    if (name_len > HOSTNAME_MAX_LENGTH)
    {
        return;
    }

    index = SIMPLE_LINK_HCI_CMND_TRANSPORT_HEADER_SIZE;

    // 32 bit to char
    int_to_stream(wlan_tx_buf, (index + 0), 8);
    int_to_stream(wlan_tx_buf, (index + 4), name_len);
    // array to stream
    // todo
    array_to_stream(wlan_tx_buf, hostname, (index + 8), name_len);

    // fill wlan_tx_buf and send command
    pkg_cmd(c_wifi,
            wlan_tx_buf,
            HCI_CMND_GETHOSTNAME,
            (SOCKET_GET_HOST_BY_NAME_PARAMS_LEN + name_len - 1));

    // get result
    c_wifi :> int _;

    // update IP address
    // out_ip_addr
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
//!                  If a message is too long to fit in the supplied buffer,
//!                  excess bytes may be discarded depending on the type of
//!                  socket the message is received from
//
//*****************************************************************************
static int simple_link_recv(chanend c_wifi,
                            long sd,
                            unsigned char buf[],
                            long len,
                            long flags,
                            skt_addr_t &from,
                            skt_len_t &from_len,
                            long opcode)
{
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
    c_wifi :> int _;

    // todo
    // In case the number of bytes is more then zero - read data
    //
        // Wait for the data in a synchronous way. Here we assume that the bug is big enough
        // to store also parameters of receive from too....

    //return(tSocketReadEvent.iNumberOfBytes);
    return 0;
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
                            long sd,
                            char buf[],
                            long len,
                            long flags,
                            skt_addr_t &to,
                            long tolen,
                            long opcode)
{
    // TODO TODO TODO TODO TODO TODO TODO TODO
    /*
    unsigned char uArgSize,  addrlen;
    unsigned char *ptr, *pDataPtr, *args;
    unsigned long addr_offset;
    int res;


    //
    // Check the bsd_arguments
    //
    // TODO - need add checking of flags ...
    if (0 != (res = HostFlowControlConsumeBuff(sd)))
    {
        return res;
    }

        //Update the number of sent packets
    tSLInformation.NumberOfSentPackets++;

    //
    // Allocate a buffer and construct a packet and send it over spi
    //
    ptr = tSLInformation.pucTxCommandBuffer;
    args = (ptr + HEADERS_SIZE_DATA);

    //
    // Update the offset of data and parameters according to the command
    switch(opcode)
    {
        case HCI_CMND_SENDTO:
        {
            addr_offset = len + sizeof(len) + sizeof(len);
            addrlen = 8;
            uArgSize = SOCKET_SENDTO_PARAMS_LEN;
            pDataPtr = ptr + HEADERS_SIZE_DATA + SOCKET_SENDTO_PARAMS_LEN;
            break;
        }

        case HCI_CMND_SEND:
        {
            tolen = 0;
            to = NULL;
            uArgSize = HCI_CMND_SEND_ARG_LENGTH;
            pDataPtr = ptr + HEADERS_SIZE_DATA + HCI_CMND_SEND_ARG_LENGTH;
            break;
        }

        default:
        {
            break;
        }
    }

    //
    // Fill in temporary command buffer
    //
    args = UINT32_TO_STREAM(args, sd);
    args = UINT32_TO_STREAM(args, uArgSize - sizeof(sd));
    args = UINT32_TO_STREAM(args, len);
    args = UINT32_TO_STREAM(args, flags);

    if (opcode == HCI_CMND_SENDTO)
    {
        args = UINT32_TO_STREAM(args, addr_offset);
        args = UINT32_TO_STREAM(args, addrlen);
    }


    //
    // Copy the data received from user into the TX Buffer
    //
    ARRAY_TO_STREAM(pDataPtr, ((unsigned char *)buf), len);

    //
    // In case we are using SendTo, copy the to parameters
    //
    if (opcode == HCI_CMND_SENDTO)
    {

        ARRAY_TO_STREAM(pDataPtr, ((unsigned char *)to), tolen);
    }

    //
    // Initiate a HCI command
    //
    hci_data_send(opcode, ptr, uArgSize, len,
                                         (unsigned char*)to, tolen);

    return  (len);
    */
    return 0;
}

/*==========================================================================*/
