#include "wifi_init.h"
#include "wlan.h"
#include "hci.h"

char my_ssid[] = {'X', 'M', 'O', 'S', ' ', 'C', 'h', 'e', 'n', 'n', 'a', 'i'};
int my_ssid_len = 12;
unsigned char my_key[] = {'x', 'm', 'o', 's', '0', '1', '1', '5'};
int my_key_len = 8;

void wifi_spi_init()
{
    //char *ssid = my_ssid;
    //unsigned char *key = my_key;
    wlan_start(0);
    //wlan_ioctl_set_connection_policy(0, 0, 0);
    //wlan_connect(WLAN_SEC_WPA2, ssid, my_ssid_len, 0, key, my_key_len);
    //wlan_set_event_mask(HCI_EVNT_WLAN_KEEPALIVE|HCI_EVNT_WLAN_UNSOL_INIT|HCI_EVNT_WLAN_UNSOL_DHCP|HCI_EVNT_WLAN_ASYNC_PING_REPORT);
}
