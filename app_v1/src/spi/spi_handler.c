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
#include "spi_handler.h"
#include "hci.h"

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/
#define READ                    3
#define WRITE                   1
#define HI(value)               (((value) & 0xFF00) >> 8)
#define LO(value)               ((value) & 0x00FF)
#define HEADERS_SIZE_EVNT       (SPI_HEADER_SIZE + 5)

#define eSPI_STATE_POWERUP 				 (0)
#define eSPI_STATE_INITIALIZED  		 (1)
#define eSPI_STATE_IDLE					 (2)
#define eSPI_STATE_WRITE_IRQ	   		 (3)
#define eSPI_STATE_WRITE_FIRST_PORTION   (4)
#define eSPI_STATE_WRITE_EOT			 (5)
#define eSPI_STATE_READ_IRQ				 (6)
#define eSPI_STATE_READ_FIRST_PORTION	 (7)
#define eSPI_STATE_READ_EOT				 (8)
#define SPI_BUFFER_SIZE					 (1700)

/*---------------------------------------------------------------------------
 ports and clocks
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 typedefs
 ---------------------------------------------------------------------------*/
typedef struct spi_hdr_t_
{
    unsigned char   cmd;
    unsigned short  length;
    unsigned char   pad[2];
}spi_hdr_t;

typedef struct spi_info_t_
{
	unsigned short tx_length;
	unsigned short rx_length;
	unsigned long  state;
	unsigned char *tx_pkt;
	unsigned char *rx_pkt;
}spi_info_t;

/*---------------------------------------------------------------------------
 global variables
 ---------------------------------------------------------------------------*/
spi_info_t spi_info;
char spi_buffer[SPI_BUFFER_SIZE];
unsigned char wlan_tx_buffer[SPI_BUFFER_SIZE];

/*---------------------------------------------------------------------------
 static variables
 ---------------------------------------------------------------------------*/
// Static buffer for 5 bytes of SPI HEADER
static spi_hdr_t spi_read_hdr = {READ, 0, "0"};

/*---------------------------------------------------------------------------
 static prototypes
 ---------------------------------------------------------------------------*/
static void spiw_read_header();
static int  spiw_read_data();
static void spiw_rx_processing();
static void spiw_cont_read();

/*---------------------------------------------------------------------------
 spiw_read_header
 ---------------------------------------------------------------------------*/
static void spiw_read_header()
{
	spi_read(spi_info.rx_pkt, 10);
}

/*---------------------------------------------------------------------------
 spiw_read_data
 ---------------------------------------------------------------------------*/
static int spiw_read_data()
{
    hci_hdr_t *hci_hdr;
    int data_to_recv;
	hci_evnt_hdr_t *hci_evnt_hdr;
	unsigned char *evnt_buff;
	hci_data_hdr_t *data_hdr;

    //determine what type of packet we have
    evnt_buff =  spi_info.rx_pkt;
    data_to_recv = 0;
	hci_hdr = (hci_hdr_t *)(evnt_buff + sizeof(spi_hdr_t));

    switch(hci_hdr->type)
    {
        case HCI_TYPE_DATA:
        {
			data_hdr = (hci_data_hdr_t *)(evnt_buff + sizeof(spi_hdr_t));

			// We need to read the rest of data..
			data_to_recv = data_hdr->length;

			if (!((HEADERS_SIZE_EVNT + data_to_recv) & 1))
			{
    	        data_to_recv++;
			}

			if (data_to_recv)
			{
            	spi_read(evnt_buff + 10, data_to_recv);
			}
            break;
        }
        case HCI_TYPE_EVNT:
        {
            //configure buffer to read rest of the data
            hci_evnt_hdr = (hci_evnt_hdr_t *)hci_hdr;

			// Calculate the rest length of the data
            data_to_recv = hci_evnt_hdr->length - 1;

			// Add padding byte if needed
			if ((HEADERS_SIZE_EVNT + data_to_recv) & 1)
			{
	            data_to_recv++;
			}

			if (data_to_recv)
			{
            	spi_read(evnt_buff + 10, data_to_recv);
			}

			spi_info.state = eSPI_STATE_READ_EOT;
            
            break;
        }
    }

    return (0);
}

/*---------------------------------------------------------------------------
 spiw_rx_processing
 ---------------------------------------------------------------------------*/
static void spiw_rx_processing()
{
	spi_info.state = eSPI_STATE_IDLE;
	//spi_info.rx_handler(spi_info.rx_pkt + sizeof(spi_hdr_t));
}

/*---------------------------------------------------------------------------
 spiw_cont_read
 ---------------------------------------------------------------------------*/
static void spiw_cont_read()
{
	if (!spiw_read_data())
	{
		spiw_rx_processing();
	}
}

/*---------------------------------------------------------------------------
 spih_open
 ---------------------------------------------------------------------------*/
void spih_open()
{
	spi_info.tx_length = 0;
    spi_info.rx_length = 0;
    spi_info.state = eSPI_STATE_POWERUP;
	spi_info.tx_pkt = 0;
	spi_info.rx_pkt = (unsigned char *)spi_buffer;
    spi_init();
}

/*---------------------------------------------------------------------------
 spih_close
 ---------------------------------------------------------------------------*/
void spih_close()
{
    if (spi_info.rx_pkt)
    {
        spi_info.rx_pkt = 0;
    }
    spi_shutdown();
}

/*---------------------------------------------------------------------------
 spih_write
 ---------------------------------------------------------------------------*/
void spih_write(unsigned char *user_buffer, unsigned short num_bytes)
{
    unsigned char padding = 0;

    // Padding required - 16 bit aligned
    if(!(num_bytes & 0x0001)) { padding = 1; }

    // Prepare SPI header
    user_buffer[0] = WRITE;
    user_buffer[1] = HI(num_bytes + padding);
    user_buffer[2] = LO(num_bytes + padding);
    user_buffer[3] = 0;
    user_buffer[4] = 0;

    num_bytes += (sizeof(spi_hdr_t) + padding);

	if (spi_info.state == eSPI_STATE_POWERUP)
	{
		while (spi_info.state != eSPI_STATE_INITIALIZED);
	}

	if (spi_info.state == eSPI_STATE_INITIALIZED)
	{
		// Power up, IRQ is down - send read buffer size command
		spi_first_write(user_buffer, num_bytes);
        spi_info.state = eSPI_STATE_IDLE;
	}
	else
	{
		while(spi_info.state != eSPI_STATE_IDLE);

		spi_info.state = eSPI_STATE_WRITE_IRQ;
		spi_info.tx_pkt = user_buffer;
		spi_info.tx_length = num_bytes;
	}

	while (eSPI_STATE_IDLE != spi_info.state);
}

/*---------------------------------------------------------------------------
 spi_irq_handler
 ---------------------------------------------------------------------------*/
void spih_irq_handler()
{
    if (spi_info.state == eSPI_STATE_POWERUP)
    {
        // This means IRQ line was low call a callback of HCI Layer to inform on event
        spi_info.state = eSPI_STATE_INITIALIZED;
    }
    else if (spi_info.state == eSPI_STATE_IDLE)
    {
        spi_info.state = eSPI_STATE_READ_IRQ;
        spiw_read_header();
        spi_info.state = eSPI_STATE_READ_EOT;
        spiw_cont_read();
    }
    else if (spi_info.state == eSPI_STATE_WRITE_IRQ)
    {
        spi_write(spi_info.tx_pkt, spi_info.tx_length);
        spi_info.state = eSPI_STATE_IDLE;
    }
}

/*==========================================================================*/
