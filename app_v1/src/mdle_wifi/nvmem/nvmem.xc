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
#include "nvmem.h"
#include "hci.h"
#include "socket.h"
#include "hci_helper.h"
#include "wifi_conf_defines.h"

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/
#define NVMEM_READ_PARAMS_LEN   (12)
#define NVMEM_WRITE_PARAMS_LEN  (16)

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

/*==========================================================================*/
/*
 * \brief Write data to nvmem.
 *
 * writes data to file referred by the ulFileId parameter.
 * Writes data to file  ulOffset till ulLength. The file id will be
 * marked invalid till the write is done. The file entry doesn't
 * need to be valid - only allocated.
 *
 * \param[in] ulFileId   nvmem file id:\n
 * NVMEM_NVS_FILEID, NVMEM_NVS_SHADOW_FILEID,
 * NVMEM_WLAN_CONFIG_FILEID, NVMEM_WLAN_CONFIG_SHADOW_FILEID,
 * NVMEM_WLAN_DRIVER_SP_FILEID, NVMEM_WLAN_FW_SP_FILEID,
 * NVMEM_MAC_FILEID, NVMEM_FRONTEND_VARS_FILEID,
 * NVMEM_IP_CONFIG_FILEID, NVMEM_IP_CONFIG_SHADOW_FILEID,
 * NVMEM_BOOTLOADER_SP_FILEID or NVMEM_RM_FILEID.
 * \param[in] ulLength    number of bytes to write
 * \param[in] ulEntryOffset  offset in file to start write operation from
 * \param[in] buff      data to write
 *
 * \return    on succes 0, error otherwise.
 *
 * \sa
 * \note
 * \warning
 *
 */
signed long nvmem_write(chanend c_wifi,
                        unsigned long file_id,
                        unsigned long length,
                        unsigned long entry_offset,
                        unsigned char buf[])
{
    long ires;
    int index;
    ires = 0;

    index = SPI_HEADER_SIZE + HCI_DATA_CMD_HEADER_SIZE;

    // 32 bit to char
    int_to_stream(wlan_tx_buf, (index + 0), file_id);
    int_to_stream(wlan_tx_buf, (index + 4), 12);
    int_to_stream(wlan_tx_buf, (index + 8), length);
    int_to_stream(wlan_tx_buf, (index + 12), entry_offset);

    // TODO this:
    /*
    memcpy((ptr + SPI_HEADER_SIZE + HCI_DATA_CMD_HEADER_SIZE + NVMEM_WRITE_PARAMS_LEN),
            buff,
            ulLength);
    */

    // fill wlan_tx_buf and send command
    pkg_data_cmd(c_wifi,
            wlan_tx_buf,
            HCI_CMND_NVMEM_WRITE,
            NVMEM_READ_PARAMS_LEN,
            length);

    // TODO get ires
    c_wifi :> int _;

    return(ires);
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void nvmem_read(chanend c_wifi,
                unsigned long file_id,
                unsigned long length,
                unsigned long offset,
                unsigned char buf[])
{
    // 32 bit to char
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 0), file_id);
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 4), length);
    int_to_stream(wlan_tx_buf, (HEADERS_SIZE_CMD + 8), offset);

    // fill wlan_tx_buf and send command
    pkg_cmd(c_wifi,
            wlan_tx_buf,
            HCI_CMND_NVMEM_READ,
            NVMEM_READ_PARAMS_LEN);

    // TODO get result into buf
    c_wifi :> int _;
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void nvmem_set_mac_address(chanend c_wifi, unsigned char mac[])
{
    nvmem_write(c_wifi, NVMEM_MAC_FILEID, MAC_ADDR_LEN, 0, mac);
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void nvmem_get_mac_address(chanend c_wifi, unsigned char mac[])
{
    nvmem_read(c_wifi, NVMEM_MAC_FILEID, MAC_ADDR_LEN, 0, mac);
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void nvmem_write_patch(chanend c_wifi,
                       unsigned long file_id,
                       unsigned long length,
                       unsigned char sp_data[])
{
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void nvmem_read_sp_version(chanend c_wifi,
                           unsigned char patch_ver[])
{
    // fill wlan_tx_buf and send command
    pkg_cmd(c_wifi,
            wlan_tx_buf,
            HCI_CMND_READ_SP_VERSION,
            0);

    // TODO get result into buf
    c_wifi :> int _;
}

/*==========================================================================*/
