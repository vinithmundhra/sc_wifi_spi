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
#include "event_handler.h"
#include "wifi_conf_defines.h"
#include "hci_helper.h"
#include "netapp.h"

#define ENABLE_XSCOPE 1

#if ENABLE_XSCOPE == 1
#include <print.h>
#include <xscope.h>
#endif

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/
#define FLOW_CONTROL_EVENT_HANDLE_OFFSET            (0)
#define FLOW_CONTROL_EVENT_BLOCK_MODE_OFFSET        (1)
#define FLOW_CONTROL_EVENT_FREE_BUFFS_OFFSET        (2)
#define FLOW_CONTROL_EVENT_SIZE                     (4)

#define BSD_RSP_PARAMS_SOCKET_OFFSET                (0)
#define BSD_RSP_PARAMS_STATUS_OFFSET                (4)

#define GET_HOST_BY_NAME_RETVAL_OFFSET              (0)
#define GET_HOST_BY_NAME_ADDR_OFFSET                (4)

#define ACCEPT_SD_OFFSET                            (0)
#define ACCEPT_RETURN_STATUS_OFFSET                 (4)
#define ACCEPT_ADDRESS__OFFSET                      (8)

#define SL_RECEIVE_SD_OFFSET                        (0)
#define SL_RECEIVE_NUM_BYTES_OFFSET                 (4)
#define SL_RECEIVE__FLAGS__OFFSET                   (8)

#define SELECT_STATUS_OFFSET                        (0)
#define SELECT_READFD_OFFSET                        (4)
#define SELECT_WRITEFD_OFFSET                       (8)
#define SELECT_EXFD_OFFSET                          (12)

#define NETAPP_IPCONFIG_IP_OFFSET                   (0)
#define NETAPP_IPCONFIG_SUBNET_OFFSET               (4)
#define NETAPP_IPCONFIG_GW_OFFSET                   (8)
#define NETAPP_IPCONFIG_DHCP_OFFSET                 (12)
#define NETAPP_IPCONFIG_DNS_OFFSET                  (16)
#define NETAPP_IPCONFIG_MAC_OFFSET                  (20)
#define NETAPP_IPCONFIG_SSID_OFFSET                 (26)

#define NETAPP_IPCONFIG_MAC_LENGTH                  (6)
#define NETAPP_IPCONFIG_SSID_LENGTH                 (32)

#define NETAPP_PING_PACKETS_SENT_OFFSET             (0)
#define NETAPP_PING_PACKETS_RCVD_OFFSET             (4)
#define NETAPP_PING_MIN_RTT_OFFSET                  (8)
#define NETAPP_PING_MAX_RTT_OFFSET                  (12)
#define NETAPP_PING_AVG_RTT_OFFSET                  (16)

#define GET_SCAN_RESULTS_TABlE_COUNT_OFFSET         (0)
#define GET_SCAN_RESULTS_SCANRESULT_STATUS_OFFSET   (4)
#define GET_SCAN_RESULTS_ISVALID_TO_SSIDLEN_OFFSET  (8)
#define GET_SCAN_RESULTS_FRAME_TIME_OFFSET          (10)
#define GET_SCAN_RESULTS_SSID_MAC_LENGTH            (38)

/*---------------------------------------------------------------------------
 ports and clocks
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 typedefs
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 global variables
 ---------------------------------------------------------------------------*/
extern sl_info_t sl_info;

unsigned long socket_active_status = SOCKET_STATUS_INIT_VAL;

/*---------------------------------------------------------------------------
 static variables
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 static prototypes
 ---------------------------------------------------------------------------*/
int handle_event_unsol(chanend c_wifi, unsigned char buf[]);

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
int event_handler(chanend c_wifi, unsigned char buf[], unsigned short len)
{
    int event_opcode;
    int index;
    int arg_size;
    int length;
    int temp = 0;

    if(buf[0] == HCI_TYPE_EVNT)
    {
        // Handle unsolicited events
        if(handle_event_unsol(c_wifi, buf) == 1)
        {
            // not an unsolicited event
            // a command respose event
            event_opcode = stream_to_short(buf, HCI_EVENT_OPCODE_OFFSET);
            index = HCI_EVENT_HEADER_SIZE;

            switch(event_opcode)
            {
                case HCI_CMND_READ_BUFFER_SIZE:                         { printstrln("HCI_CMND_READ_BUFFER_SIZE:                   "); c_wifi <: temp; break; }
                case HCI_CMND_WLAN_CONFIGURE_PATCH:                     { printstrln("HCI_CMND_WLAN_CONFIGURE_PATCH:               "); c_wifi <: temp; break; }
                case HCI_NETAPP_DHCP:                                   { printstrln("HCI_NETAPP_DHCP:                             "); c_wifi <: temp; break; }
                case HCI_NETAPP_PING_SEND:                              { printstrln("HCI_NETAPP_PING_SEND:                        "); c_wifi <: temp; break; }
                case HCI_NETAPP_PING_STOP:                              { printstrln("HCI_NETAPP_PING_STOP:                        "); c_wifi <: temp; break; }
                case HCI_NETAPP_ARP_FLUSH:                              { printstrln("HCI_NETAPP_ARP_FLUSH:                        "); c_wifi <: temp; break; }
                case HCI_NETAPP_SET_DEBUG_LEVEL:                        { printstrln("HCI_NETAPP_SET_DEBUG_LEVEL:                  "); c_wifi <: temp; break; }
                case HCI_NETAPP_SET_TIMERS:                             { printstrln("HCI_NETAPP_SET_TIMERS:                       "); c_wifi <: temp; break; }
                case HCI_EVNT_NVMEM_READ:                               { printstrln("HCI_EVNT_NVMEM_READ:                         "); c_wifi <: temp; break; }
                case HCI_EVNT_NVMEM_CREATE_ENTRY:                       { printstrln("HCI_EVNT_NVMEM_CREATE_ENTRY:                 "); c_wifi <: temp; break; }
                case HCI_CMND_NVMEM_WRITE_PATCH:                        { printstrln("HCI_CMND_NVMEM_WRITE_PATCH:                  "); c_wifi <: temp; break; }
                case HCI_NETAPP_PING_REPORT:                            { printstrln("HCI_NETAPP_PING_REPORT:                      "); c_wifi <: temp; break; }
                case HCI_CMND_SETSOCKOPT:                               { printstrln("HCI_CMND_SETSOCKOPT:                         "); c_wifi <: temp; break; }
                case HCI_CMND_WLAN_CONNECT:                             { printstrln("HCI_CMND_WLAN_CONNECT:                       "); c_wifi <: temp; break; }
                case HCI_CMND_WLAN_IOCTL_STATUSGET:                     { printstrln("HCI_CMND_WLAN_IOCTL_STATUSGET:               "); c_wifi <: temp; break; }
                case HCI_EVNT_WLAN_IOCTL_ADD_PROFILE:                   { printstrln("HCI_EVNT_WLAN_IOCTL_ADD_PROFILE:             "); c_wifi <: temp; break; }
                case HCI_CMND_WLAN_IOCTL_DEL_PROFILE:                   { printstrln("HCI_CMND_WLAN_IOCTL_DEL_PROFILE:             "); c_wifi <: temp; break; }
                case HCI_CMND_WLAN_IOCTL_SET_CONNECTION_POLICY:         { printstrln("HCI_CMND_WLAN_IOCTL_SET_CONNECTION_POLICY:   "); c_wifi <: temp; break; }
                case HCI_CMND_WLAN_IOCTL_SET_SCANPARAM:                 { printstrln("HCI_CMND_WLAN_IOCTL_SET_SCANPARAM:           "); c_wifi <: temp; break; }
                case HCI_CMND_WLAN_IOCTL_SIMPLE_CONFIG_START:           { printstrln("HCI_CMND_WLAN_IOCTL_SIMPLE_CONFIG_START:     "); c_wifi <: temp; break; }
                case HCI_CMND_WLAN_IOCTL_SIMPLE_CONFIG_STOP:            { printstrln("HCI_CMND_WLAN_IOCTL_SIMPLE_CONFIG_STOP:      "); c_wifi <: temp; break; }
                case HCI_CMND_WLAN_IOCTL_SIMPLE_CONFIG_SET_PREFIX:      { printstrln("HCI_CMND_WLAN_IOCTL_SIMPLE_CONFIG_SET_PREFIX:"); c_wifi <: temp; break; }
                case HCI_CMND_EVENT_MASK:                               { printstrln("HCI_CMND_EVENT_MASK:                         "); c_wifi <: temp; break; }
                case HCI_EVNT_WLAN_DISCONNECT:                          { printstrln("HCI_EVNT_WLAN_DISCONNECT:                    "); c_wifi <: temp; break; }
                case HCI_EVNT_SOCKET:                                   { printstrln("HCI_EVNT_SOCKET:                             "); c_wifi <: temp; break; }
                case HCI_EVNT_BIND:                                     { printstrln("HCI_EVNT_BIND:                               "); c_wifi <: temp; break; }
                case HCI_CMND_LISTEN:                                   { printstrln("HCI_CMND_LISTEN:                             "); c_wifi <: temp; break; }
                case HCI_EVNT_CLOSE_SOCKET:                             { printstrln("HCI_EVNT_CLOSE_SOCKET:                       "); c_wifi <: temp; break; }
                case HCI_EVNT_CONNECT:                                  { printstrln("HCI_EVNT_CONNECT:                            "); c_wifi <: temp; break; }
                case HCI_EVNT_NVMEM_WRITE:                              { printstrln("HCI_EVNT_NVMEM_WRITE:                        "); c_wifi <: temp; break; }
                case HCI_EVNT_READ_SP_VERSION:                          { printstrln("HCI_EVNT_READ_SP_VERSION:                    "); c_wifi <: temp; break; }
                case HCI_EVNT_BSD_GETHOSTBYNAME:                        { printstrln("HCI_EVNT_BSD_GETHOSTBYNAME:                  "); c_wifi <: temp; break; }
                case HCI_EVNT_ACCEPT:                                   { printstrln("HCI_EVNT_ACCEPT:                             "); c_wifi <: temp; break; }
                case HCI_EVNT_RECV:                                     { printstrln("HCI_EVNT_RECV:                               "); c_wifi <: temp; break; }
                case HCI_EVNT_RECVFROM:                                 { printstrln("HCI_EVNT_RECVFROM:                           "); c_wifi <: temp; break; }
                case HCI_EVNT_SELECT:                                   { printstrln("HCI_EVNT_SELECT:                             "); c_wifi <: temp; break; }
                case HCI_CMND_GETSOCKOPT:                               { printstrln("HCI_CMND_GETSOCKOPT:                         "); c_wifi <: temp; break; }
                case HCI_CMND_WLAN_IOCTL_GET_SCAN_RESULTS:              { printstrln("HCI_CMND_WLAN_IOCTL_GET_SCAN_RESULTS:        "); c_wifi <: temp; break; }
                case HCI_CMND_SIMPLE_LINK_START:                        { printstrln("HCI_CMND_SIMPLE_LINK_START:                  "); c_wifi <: temp; break; }
                case HCI_NETAPP_IPCONFIG:                               { printstrln("HCI_NETAPP_IPCONFIG:                         "); c_wifi <: temp; break; }
                default:                                                { printstrln("Unrecognized event"); break; }
            } // switch(event_opcode)
        } // if(handle_event_unsol(c_wifi, buf) == 1)
    } // if(buf[0] == HCI_TYPE_EVNT)
    return 0;
}

/*---------------------------------------------------------------------------
 implementation2
 ---------------------------------------------------------------------------*/
int handle_event_unsol(chanend c_wifi, unsigned char buf[])
{
    int event_opcode = stream_to_short(buf, HCI_EVENT_OPCODE_OFFSET);
    int rtnval = 0;

    switch(event_opcode)
    {
        case HCI_EVNT_WLAN_ASYNC_SIMPLE_CONFIG_DONE:
        {
            printstrln("HCI_EVNT_WLAN_ASYNC_SIMPLE_CONFIG_DONE");
            c_wifi <: rtnval;
            break;
        }
        case HCI_EVNT_WLAN_KEEPALIVE:
        {
            printstrln("HCI_EVNT_WLAN_KEEPALIVE");
            c_wifi <: rtnval;
            break;
        }
        case HCI_EVNT_WLAN_UNSOL_CONNECT:
        {
            printstrln("HCI_EVNT_WLAN_UNSOL_CONNECT");
            c_wifi <: rtnval;
            break;
        }
        case HCI_EVNT_WLAN_UNSOL_DISCONNECT:
        {
            printstrln("HCI_EVNT_WLAN_UNSOL_DISCONNECT");
            c_wifi <: rtnval;
            break;
        }
        case HCI_EVNT_WLAN_UNSOL_DHCP:
        {
            printstrln("HCI_EVNT_WLAN_UNSOL_DHCP");
            c_wifi <: rtnval;
            break;
        }
        case HCI_EVNT_WLAN_UNSOL_INIT:
        {
            printstrln("HCI_EVNT_WLAN_UNSOL_INIT");
            c_wifi <: rtnval;
            break;
        }
        case HCI_EVNT_WLAN_ASYNC_PING_REPORT:
        {
            printstrln("HCI_EVNT_WLAN_ASYNC_PING_REPORT");
            c_wifi <: rtnval;
            break;
        }
        default:
        {
            rtnval = 1;
            break;
        }
    } // switch(event_opcode)

    return rtnval;
}

/*==========================================================================*/
