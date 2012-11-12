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
#include "tiwisl_event_handler.h"
#include "hci_helper.h"
#include "hci_defines.h"
#include "notify.h"
#include <string.h>
#include <print.h>

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/
#define FLOW_CONTROL_EVENT_HANDLE_OFFSET        (0)
#define FLOW_CONTROL_EVENT_BLOCK_MODE_OFFSET    (1)
#define FLOW_CONTROL_EVENT_FREE_BUFFS_OFFSET    (2)
#define FLOW_CONTROL_EVENT_SIZE                 (4)

#define BSD_RSP_PARAMS_SOCKET_OFFSET        (0)
#define BSD_RSP_PARAMS_STATUS_OFFSET        (4)

#define GET_HOST_BY_NAME_RETVAL_OFFSET  (0)
#define GET_HOST_BY_NAME_ADDR_OFFSET    (4)

#define ACCEPT_SD_OFFSET            (0)
#define ACCEPT_RETURN_STATUS_OFFSET (4)
#define ACCEPT_ADDRESS__OFFSET      (8)

#define SL_RECEIVE_SD_OFFSET            (0)
#define SL_RECEIVE_NUM_BYTES_OFFSET     (4)
#define SL_RECEIVE__FLAGS__OFFSET       (8)

#define SELECT_STATUS_OFFSET            (0)
#define SELECT_READFD_OFFSET            (4)
#define SELECT_WRITEFD_OFFSET           (8)
#define SELECT_EXFD_OFFSET              (12)

#define NETAPP_IPCONFIG_IP_OFFSET               (0)
#define NETAPP_IPCONFIG_SUBNET_OFFSET           (4)
#define NETAPP_IPCONFIG_GW_OFFSET               (8)
#define NETAPP_IPCONFIG_DHCP_OFFSET             (12)
#define NETAPP_IPCONFIG_DNS_OFFSET              (16)
#define NETAPP_IPCONFIG_MAC_OFFSET              (20)
#define NETAPP_IPCONFIG_SSID_OFFSET             (26)

#define NETAPP_IPCONFIG_MAC_LENGTH              (6)
#define NETAPP_IPCONFIG_SSID_LENGTH             (32)

#define NETAPP_PING_PACKETS_SENT_OFFSET         (0)
#define NETAPP_PING_PACKETS_RCVD_OFFSET         (4)
#define NETAPP_PING_MIN_RTT_OFFSET              (8)
#define NETAPP_PING_MAX_RTT_OFFSET              (12)
#define NETAPP_PING_AVG_RTT_OFFSET              (16)

#define GET_SCAN_RESULTS_TABlE_COUNT_OFFSET             (0)
#define GET_SCAN_RESULTS_SCANRESULT_STATUS_OFFSET       (4)
#define GET_SCAN_RESULTS_ISVALID_TO_SSIDLEN_OFFSET      (8)
#define GET_SCAN_RESULTS_FRAME_TIME_OFFSET              (10)
#define GET_SCAN_RESULTS_SSID_MAC_LENGTH                (38)

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
xtcp_ipconfig_t tiwisl_ipconfig;
xtcp_connection_t conn;

/*---------------------------------------------------------------------------
 static prototypes
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
int tiwisl_event_handler(chanend c_xtcp, int conn_id, unsigned char *ret_buf)
{
    unsigned char *rx_data;
    unsigned char *rx_params;
    unsigned char arg_size;
    unsigned short len, rx_event;

    rx_data = tiwisl_buf;

    if (*rx_data == HCI_TYPE_EVNT)
    {
        // Event Received
        rx_event = stream_to_short((char *) rx_data, HCI_EVENT_OPCODE_OFFSET);
        len = stream_to_char((char *) rx_data, HCI_DATA_LENGTH_OFFSET);
        rx_params = rx_data + HCI_EVENT_HEADER_SIZE;

        printstr("Event : "); printintln(rx_event);

        switch (rx_event)
        {
            case HCI_EVNT_WLAN_UNSOL_DHCP:
            {
                /*
                 * Could have used this but the addresses returned are in reverse order (LSB first)
                 * memcpy((unsigned char *)(&tiwisl_ipconfig), (unsigned char *)(rx_params), sizeof(xtcp_ipconfig_t));
                 */

                tiwisl_ipconfig.ipaddr[3] = stream_to_char((char *)(rx_params), NETAPP_IPCONFIG_IP_OFFSET + 0);
                tiwisl_ipconfig.ipaddr[2] = stream_to_char((char *)(rx_params), NETAPP_IPCONFIG_IP_OFFSET + 1);
                tiwisl_ipconfig.ipaddr[1] = stream_to_char((char *)(rx_params), NETAPP_IPCONFIG_IP_OFFSET + 2);
                tiwisl_ipconfig.ipaddr[0] = stream_to_char((char *)(rx_params), NETAPP_IPCONFIG_IP_OFFSET + 3);

                tiwisl_ipconfig.netmask[3] = stream_to_char((char *)(rx_params), NETAPP_IPCONFIG_SUBNET_OFFSET + 0);
                tiwisl_ipconfig.netmask[2] = stream_to_char((char *)(rx_params), NETAPP_IPCONFIG_SUBNET_OFFSET + 1);
                tiwisl_ipconfig.netmask[1] = stream_to_char((char *)(rx_params), NETAPP_IPCONFIG_SUBNET_OFFSET + 2);
                tiwisl_ipconfig.netmask[0] = stream_to_char((char *)(rx_params), NETAPP_IPCONFIG_SUBNET_OFFSET + 3);

                tiwisl_ipconfig.gateway[3] = stream_to_char((char *)(rx_params), NETAPP_IPCONFIG_GW_OFFSET + 0);
                tiwisl_ipconfig.gateway[2] = stream_to_char((char *)(rx_params), NETAPP_IPCONFIG_GW_OFFSET + 1);
                tiwisl_ipconfig.gateway[1] = stream_to_char((char *)(rx_params), NETAPP_IPCONFIG_GW_OFFSET + 2);
                tiwisl_ipconfig.gateway[0] = stream_to_char((char *)(rx_params), NETAPP_IPCONFIG_GW_OFFSET + 3);


                // set the XTCP_IFUP event
                conn.id = conn_id;
                conn.event = XTCP_IFUP;

                send_notification(c_xtcp, &conn);

                break;
            } // case HCI_EVNT_WLAN_UNSOL_DHCP:

            case HCI_EVNT_ACCEPT:
            {
                *(unsigned char *)(ret_buf) = stream_to_int((char *)(rx_params), ACCEPT_SD_OFFSET);
                ret_buf = ((unsigned char *)(ret_buf)) + 4;

                *(unsigned char *)(ret_buf) = stream_to_int((char *)(rx_params), ACCEPT_RETURN_STATUS_OFFSET);
                ret_buf = ((unsigned char *)(ret_buf)) + 4;

                //This argurment returns in network order, therefore the use of memcpy.
                //memcpy((unsigned char *)(ret_buf), rx_params, sizeof(sockaddr));

                break;
            } // case HCI_EVNT_ACCEPT:

            case HCI_EVNT_RECV:
            case HCI_EVNT_RECVFROM:
            {
                *(unsigned char *) ret_buf = stream_to_int((char *) rx_params, SL_RECEIVE_SD_OFFSET);
                ret_buf = ((unsigned char *) ret_buf) + 4;

                *(unsigned char *) ret_buf = stream_to_int((char *) rx_params, SL_RECEIVE_NUM_BYTES_OFFSET);
                ret_buf = ((unsigned char *) ret_buf) + 4;

                *(unsigned char *) ret_buf = stream_to_int((char *) rx_params, SL_RECEIVE__FLAGS__OFFSET);

                break;
            }

            case HCI_EVNT_WLAN_DISCONNECT:
            {
                conn.id = conn_id;
                conn.event = XTCP_IFDOWN;
                send_notification(c_xtcp, &conn);
                break;
            }

            default:
            {
                /*
                 * some of these are TODO
                case HCI_EVNT_DATA_UNSOL_FREE_BUFF:
                case HCI_CMND_WLAN_CONFIGURE_PATCH:
                case HCI_NETAPP_DHCP:
                case HCI_NETAPP_PING_SEND:
                case HCI_NETAPP_PING_STOP:
                case HCI_NETAPP_ARP_FLUSH:
                case HCI_NETAPP_SET_DEBUG_LEVEL:
                case HCI_NETAPP_SET_TIMERS:
                case HCI_EVNT_NVMEM_READ:
                case HCI_EVNT_NVMEM_CREATE_ENTRY:
                case HCI_CMND_NVMEM_WRITE_PATCH:
                case HCI_NETAPP_PING_REPORT:
                case HCI_CMND_SETSOCKOPT:
                case HCI_CMND_WLAN_CONNECT:
                case HCI_CMND_WLAN_IOCTL_STATUSGET:
                case HCI_EVNT_WLAN_IOCTL_ADD_PROFILE:
                case HCI_CMND_WLAN_IOCTL_DEL_PROFILE:
                case HCI_CMND_WLAN_IOCTL_SET_CONNECTION_POLICY:
                case HCI_CMND_WLAN_IOCTL_SET_SCANPARAM:
                case HCI_CMND_WLAN_IOCTL_SIMPLE_CONFIG_START:
                case HCI_CMND_WLAN_IOCTL_SIMPLE_CONFIG_STOP:
                case HCI_CMND_WLAN_IOCTL_SIMPLE_CONFIG_SET_PREFIX:
                case HCI_CMND_EVENT_MASK:
                case HCI_EVNT_SOCKET:
                case HCI_EVNT_BIND:
                case HCI_CMND_LISTEN:
                case HCI_EVNT_CLOSE_SOCKET:
                case HCI_EVNT_CONNECT:
                case HCI_EVNT_NVMEM_WRITE:
                case HCI_EVNT_READ_SP_VERSION:
                case HCI_EVNT_BSD_GETHOSTBYNAME:
                case HCI_EVNT_SELECT:
                case HCI_CMND_GETSOCKOPT:
                case HCI_CMND_WLAN_IOCTL_GET_SCAN_RESULTS:
                case HCI_NETAPP_IPCONFIG:
                case HCI_EVNT_WLAN_KEEPALIVE:
                case HCI_EVNT_WLAN_UNSOL_CONNECT:
                case HCI_EVNT_WLAN_UNSOL_DISCONNECT:
                case HCI_EVNT_WLAN_UNSOL_INIT:
                case HCI_EVNT_WLAN_ASYNC_PING_REPORT:
                case HCI_EVNT_WLAN_ASYNC_SIMPLE_CONFIG_DONE:
                case HCI_EVNT_SEND:
                case HCI_EVNT_SENDTO:
                case HCI_EVNT_WRITE:
                case HCI_CMND_READ_BUFFER_SIZE:
                case HCI_CMND_SIMPLE_LINK_START:
                */
                break;
            } // default:

        } // switch(rx_event)
    }
    else
    {
        /*
         * This is a Data event received (data from LSR).
         * Must check if its actually a data event: HCI_TYPE_DATA
         */
        rx_params = rx_data;
        arg_size = stream_to_char((char *) rx_data, HCI_PACKET_ARGSIZE_OFFSET);
        len = stream_to_short((char *) rx_data, HCI_PACKET_LENGTH_OFFSET);

        // TODO: copy rxd data into buffers
        //
        // Data received: note that the only case where from and from length are not null is in
        // recv from, so fill the args accordingly
        //
        /*
        if (from)
        {
            *(unsigned int *) fromlen = stream_to_int((char *) (rx_data + HCI_DATA_HEADER_SIZE), BSD_RECV_FROM_FROMLEN_OFFSET);
            memcpy(from, (rx_data + HCI_DATA_HEADER_SIZE + BSD_RECV_FROM_FROM_OFFSET), *fromlen);
        }
        */

        memcpy(ret_buf, rx_params + HCI_DATA_HEADER_SIZE + arg_size, len - arg_size);
    }

    return 0;
}

/*---------------------------------------------------------------------------
 implementation2
 ---------------------------------------------------------------------------*/
void tiwisl_get_ipconfig(xtcp_ipconfig_t *ipconfig)
{
    memcpy((unsigned char *)(ipconfig), (unsigned char *)(&tiwisl_ipconfig), sizeof(xtcp_ipconfig_t));
}

/*==========================================================================*/
