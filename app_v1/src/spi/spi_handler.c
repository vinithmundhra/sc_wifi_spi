
/*****************************************************************************
*
*  spi.c - CC3000 Host Driver Implementation.
*  Copyright (C) 2011 Texas Instruments Incorporated - http://www.ti.com/
*
*  Redistribution and use in source and binary forms, with or without
*  modification, are permitted provided that the following conditions
*  are met:
*
*    Redistributions of source code must retain the above copyright
*    notice, this list of conditions and the following disclaimer.
*
*    Redistributions in binary form must reproduce the above copyright
*    notice, this list of conditions and the following disclaimer in the
*    documentation and/or other materials provided with the   
*    distribution.
*
*    Neither the name of Texas Instruments Incorporated nor the names of
*    its contributors may be used to endorse or promote products derived
*    from this software without specific prior written permission.
*
*  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
*  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
*  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
*  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT 
*  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
*  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
*  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
*  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
*  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
*  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
*  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*
*****************************************************************************/

//*****************************************************************************
//
//! \addtogroup link_buff_api
//! @{
//
//*****************************************************************************
#include "spi_handler.h"
#include "spi_tiwisl.h"
#include "hci.h"
#include "evnt_handler.h"

#define READ                    3
#define WRITE                   1

#define HI(value)               (((value) & 0xFF00) >> 8)
#define LO(value)               ((value) & 0x00FF)
#define HEADERS_SIZE_EVNT       (SPI_HEADER_SIZE + 5)

#define SPI_HEADER_SIZE			(5)

#define eSPI_STATE_POWERUP 				 (0)
#define eSPI_STATE_INITIALIZED  		 (1)
#define eSPI_STATE_IDLE					 (2)
#define eSPI_STATE_WRITE_IRQ	   		 (3)
#define eSPI_STATE_WRITE_FIRST_PORTION   (4)
#define eSPI_STATE_WRITE_EOT			 (5)
#define eSPI_STATE_READ_IRQ				 (6)
#define eSPI_STATE_READ_FIRST_PORTION	 (7)
#define eSPI_STATE_READ_EOT				 (8)

// The magic number that resides at the end of the TX/RX buffer (1 byte after the allocated size)
// for the purpose of detection of the overrun. The location of the memory where the magic number 
// resides shall never be written. In case it is written - the overrun occured and either recevie function
// or send function will stuck forever.
#define CC3000_BUFFER_MAGIC_NUMBER (0xDE)

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
char spi_buffer[CC3000_RX_BUFFER_SIZE];
unsigned char wlan_tx_buffer[CC3000_TX_BUFFER_SIZE];

// Static buffer for 5 bytes of SPI HEADER
unsigned char spi_read_hdr[] = {READ, 0, 0, 0, 0};


/*---------------------------------------------------------------------------
 static prototypes
 ---------------------------------------------------------------------------*/
static void spiw_read_header();
static long spiw_read_data();
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
static long spiw_read_data()
{
    long data_to_recv;
	unsigned char *evnt_buff, type;

    //determine what type of packet we have
    evnt_buff =  spi_info.rx_pkt;
    data_to_recv = 0;
	STREAM_TO_UINT8((char *)(evnt_buff + SPI_HEADER_SIZE), HCI_PACKET_TYPE_OFFSET, type);

    switch(type)
    {
        case HCI_TYPE_DATA:
        {
			// We need to read the rest of data..
			STREAM_TO_UINT16((char *)(evnt_buff + SPI_HEADER_SIZE), HCI_DATA_LENGTH_OFFSET, data_to_recv);
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
			// Calculate the rest length of the data
			//
            STREAM_TO_UINT8((char *)(evnt_buff + SPI_HEADER_SIZE), HCI_EVENT_LENGTH_OFFSET, data_to_recv);
			data_to_recv -= 1;

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
    // The magic number that resides at the end of the TX/RX buffer (1 byte after the allocated size)
    // for the purpose of detection of the overrun. If the magic number is overriten - buffer overrun 
    // occurred - and we will stuck here forever!
	if (spi_info.rx_pkt[CC3000_RX_BUFFER_SIZE - 1] != CC3000_BUFFER_MAGIC_NUMBER)
	{
		while(1);
	}
	spi_info.state = eSPI_STATE_IDLE;
	// todo add receive handler here
	//SpiReceiveHandler(spi_info.rx_pkt + SPI_HEADER_SIZE);
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
    
    spi_buffer[CC3000_RX_BUFFER_SIZE - 1] = CC3000_BUFFER_MAGIC_NUMBER;
	wlan_tx_buffer[CC3000_TX_BUFFER_SIZE - 1] = CC3000_BUFFER_MAGIC_NUMBER;
    
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

    num_bytes += (SPI_HEADER_SIZE + padding);

    // The magic number that resides at the end of the TX/RX buffer (1 byte after the allocated size)
    // for the purpose of detection of the overrun. If the magic number is overriten - buffer overrun 
    // occurred - and we will stuck here forever!
	if (wlan_tx_buffer[CC3000_TX_BUFFER_SIZE - 1] != CC3000_BUFFER_MAGIC_NUMBER)
	{
		while(1);
	}
    
	if (spi_info.state == eSPI_STATE_POWERUP)
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
