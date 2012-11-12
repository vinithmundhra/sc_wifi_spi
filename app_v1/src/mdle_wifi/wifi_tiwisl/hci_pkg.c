// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*===========================================================================
 Info
 ----
 
 ===========================================================================*/

/*---------------------------------------------------------------------------
 include files
 ---------------------------------------------------------------------------*/
#include "hci_pkg.h"
#include "hci_helper.h"
#include "hci_defines.h"
#include <string.h>

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/
#define WRITE               1
#define HI(value)           (((value) & 0xFF00) >> 8)
#define LO(value)           ((value) & 0x00FF)

#define SL_SET_SCAN_PARAMS_INTERVAL_LIST_SIZE   (16)
#define SL_SIMPLE_CONFIG_PREFIX_LENGTH          (3)
#define ETH_ALEN                                (6)
#define MAXIMAL_SSID_LENGTH                     (32)

#define SL_PATCHES_REQUEST_DEFAULT              (0)
#define SL_PATCHES_REQUEST_FORCE_HOST           (1)
#define SL_PATCHES_REQUEST_FORCE_NONE           (2)

#define WLAN_SL_INIT_START_PARAMS_LEN           (1)
#define WLAN_PATCH_PARAMS_LENGTH                (8)
#define WLAN_SET_CONNECTION_POLICY_PARAMS_LEN   (12)
#define WLAN_DEL_PROFILE_PARAMS_LEN             (4)
#define WLAN_SET_MASK_PARAMS_LEN                (4)
#define WLAN_SET_SCAN_PARAMS_LEN                (100)
#define WLAN_GET_SCAN_RESULTS_PARAMS_LEN        (4)
#define WLAN_ADD_PROFILE_NOSEC_PARAM_LEN        (24)
#define WLAN_ADD_PROFILE_WEP_PARAM_LEN          (36)
#define WLAN_ADD_PROFILE_WPA_PARAM_LEN          (44)
#define WLAN_CONNECT_PARAM_LEN                  (29)


#define HOSTNAME_MAX_LENGTH     (230)  // 230 bytes + header shouldn't exceed 8 bit value
#define  ASIC_ADDR_LEN          8

//--------- Address Families --------

#define AF_INET                 2
#define AF_INET6                23

//------------ Socket Types ------------

#define SOCK_STREAM             1
#define SOCK_DGRAM              2
#define SOCK_RAW                3           // Raw sockets allow new IPv4 protocols to be implemented in user space. A raw socket receives or sends the raw datagram not including link level headers
#define SOCK_RDM                4
#define SOCK_SEQPACKET          5

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

/*---------------------------------------------------------------------------
 ports and clocks
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 typedefs
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 global variables
 ---------------------------------------------------------------------------*/
extern unsigned char tiwisl_buf[];

/*---------------------------------------------------------------------------
 static variables
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 static prototypes
 ---------------------------------------------------------------------------*/
static int hci_pkg_spi_header(unsigned char *buf, unsigned short len);

static unsigned int hci_pkg_cmd(unsigned short opcode,
                                unsigned char *buf,
                                unsigned char args_len);

static unsigned int hci_pkg_data(unsigned char opcode,
                                 unsigned char *buf,
                                 unsigned char *args,
                                 unsigned short args_len,
                                 unsigned short data_len,
                                 unsigned short tail_len);

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
static unsigned int hci_pkg_cmd(unsigned short opcode,
                                unsigned char *buf,
                                unsigned char args_len)
{ 
	unsigned char *stream;
    unsigned int len;

    len = hci_pkg_spi_header(buf, (args_len + SIMPLE_LINK_HCI_CMND_HEADER_SIZE));
    
	stream = (unsigned char *)(buf + SPI_HEADER_SIZE);	
	stream = char_to_stream(stream, HCI_TYPE_CMND);
	stream = short_to_stream(stream, opcode);
	stream = char_to_stream(stream, args_len);

    return len;
}

/*---------------------------------------------------------------------------
 implementation2
 ---------------------------------------------------------------------------*/
static unsigned int hci_pkg_data(unsigned char opcode,
                                 unsigned char *buf,
                                 unsigned char *args,
                                 unsigned short args_len,
                                 unsigned short data_len,
                                 unsigned short tail_len)
{
	unsigned char *stream;
    unsigned int len;

    len = hci_pkg_spi_header(buf, (SIMPLE_LINK_HCI_DATA_HEADER_SIZE + args_len + data_len + tail_len));
    
	stream = (unsigned char *)(args + SPI_HEADER_SIZE);
	stream = char_to_stream(stream, HCI_TYPE_DATA);
	stream = char_to_stream(stream, opcode);
	stream = char_to_stream(stream, args_len);
	stream = short_to_stream(stream, (args_len + data_len + tail_len));

    return len;
}

/*---------------------------------------------------------------------------
 pkg_spi
 ---------------------------------------------------------------------------*/
static int hci_pkg_spi_header(unsigned char *buf, unsigned short len)
{
    unsigned char *stream;
    int pad = 0;

    if(!(len & 0x0001))
    {
        pad++;
        stream = char_to_stream((buf + SPI_HEADER_SIZE + len), 0);
    }

    stream = char_to_stream(buf, WRITE);
    stream = char_to_stream(stream, HI(len + pad));
    stream = char_to_stream(stream, LO(len + pad));
    stream = char_to_stream(stream, 0);
    stream = char_to_stream(stream, 0);

    return (SPI_HEADER_SIZE + len + pad);
}

/*---------------------------------------------------------------------------
 implementation2
 ---------------------------------------------------------------------------*/
int hci_pkg_wifi_on()
{
    unsigned char *args;
    unsigned char *buf;
    int len;

    buf = tiwisl_buf;
    args = (unsigned char *)(buf + HEADERS_SIZE_CMD);
    args = char_to_stream(args, SL_PATCHES_REQUEST_DEFAULT);
    len = hci_pkg_cmd(HCI_CMND_SIMPLE_LINK_START, buf, WLAN_SL_INIT_START_PARAMS_LEN);
    return len;
}

/*---------------------------------------------------------------------------
 implementation2
 ---------------------------------------------------------------------------*/
int hci_pkg_read_buffer_size()
{
    unsigned char *buf;
    buf = tiwisl_buf;
    return hci_pkg_cmd(HCI_CMND_READ_BUFFER_SIZE, buf, 0);
}

/*---------------------------------------------------------------------------
 implementation2
 ---------------------------------------------------------------------------*/
int hci_pkg_set_event_mask(int mask)
{
    unsigned char *buf, *args;
    buf = tiwisl_buf;

    args = (buf + HEADERS_SIZE_CMD);
    args = int_to_stream(args, mask);

    return hci_pkg_cmd(HCI_CMND_EVENT_MASK, buf, WLAN_SET_MASK_PARAMS_LEN);
}

/*---------------------------------------------------------------------------
 implementation2
 ---------------------------------------------------------------------------*/
int hci_pkg_wlan_connect(wifi_ap_config_t *ap_config)
{
    unsigned char *args;
    unsigned char *buf;
    unsigned char bssid_zero[] = {0, 0, 0, 0, 0, 0}; 
    int len, ssid_len, key_len;
    
    ssid_len = strlen((char *)(ap_config->ssid));
    key_len = strlen((char *)(ap_config->key));
    
    buf = tiwisl_buf;
    args = (buf + HEADERS_SIZE_CMD);
    
    args = int_to_stream(args, 0x0000001c);
	args = int_to_stream(args, ssid_len);
	args = int_to_stream(args, ap_config->security_type);
	args = int_to_stream(args, 0x00000010 + ssid_len);
	args = int_to_stream(args, key_len);
	args = short_to_stream(args, 0);
    
    args = array_to_stream(args, bssid_zero, ETH_ALEN);
    
    array_to_stream(args, ap_config->ssid, ssid_len);

    if(key_len && ap_config->key)
    {
    	array_to_stream(args, ap_config->key, key_len);
    }
    
    len = hci_pkg_cmd(HCI_CMND_WLAN_CONNECT, buf, (WLAN_CONNECT_PARAM_LEN + ssid_len + key_len - 1));
    return len;
}

/*---------------------------------------------------------------------------
 implementation2
 ---------------------------------------------------------------------------*/
int hci_pkg_wlan_set_connection_policy(unsigned int should_connect_to_open_ap,
                                       unsigned int should_use_fast_connect,
                                       unsigned int use_profiles)
{
    int len;
    unsigned char *buf;
    unsigned char *args;

    buf = tiwisl_buf;
    args = (unsigned char *)(buf + HEADERS_SIZE_CMD);
    args = int_to_stream(args, should_connect_to_open_ap);
    args = int_to_stream(args, should_use_fast_connect);
    args = int_to_stream(args, use_profiles);

    len = hci_pkg_cmd(HCI_CMND_WLAN_IOCTL_SET_CONNECTION_POLICY, buf, WLAN_SET_CONNECTION_POLICY_PARAMS_LEN);
    return len;
}

/*---------------------------------------------------------------------------
 implementation2
 ---------------------------------------------------------------------------*/
int hci_pkg_skt_create(xtcp_protocol_t p)
{
    unsigned char *buf, *args;
    int len;

    buf = tiwisl_buf;
    args = (unsigned char *)(buf + HEADERS_SIZE_CMD);
    args = int_to_stream(args, AF_INET);
    args = int_to_stream(args, SOCK_STREAM);
    args = int_to_stream(args, p);

    len = hci_pkg_cmd(HCI_CMND_SOCKET, buf, SOCKET_OPEN_PARAMS_LEN);
    return len;
}

/*---------------------------------------------------------------------------
 implementation2
 ---------------------------------------------------------------------------*/
int hci_pkg_skt_bind(int conn_id, int port_number)
{
    unsigned char *buf, *args;
    int len;

    buf = tiwisl_buf;
    args = (unsigned char *)(buf + HEADERS_SIZE_CMD);
    args = int_to_stream(args, conn_id);
    args = int_to_stream(args, 0x00000008);
    args = int_to_stream(args, ASIC_ADDR_LEN);
    args = short_to_stream(args, AF_INET);
    args = short_to_stream(args, (short)(port_number));
    args = int_to_stream(args, 0);

    len = hci_pkg_cmd(HCI_CMND_BIND, buf, SOCKET_BIND_PARAMS_LEN);
    return len;
}

/*---------------------------------------------------------------------------
 implementation2
 ---------------------------------------------------------------------------*/
int hci_pkg_skt_listen(int conn_id)
{
    unsigned char *buf, *args;
    int len;

    buf = tiwisl_buf;
    args = (unsigned char *)(buf + HEADERS_SIZE_CMD);
    args = int_to_stream(args, conn_id);
    args = int_to_stream(args, 1);

    len = hci_pkg_cmd(HCI_CMND_LISTEN, buf, SOCKET_LISTEN_PARAMS_LEN);
    return len;
}

/*==========================================================================*/
