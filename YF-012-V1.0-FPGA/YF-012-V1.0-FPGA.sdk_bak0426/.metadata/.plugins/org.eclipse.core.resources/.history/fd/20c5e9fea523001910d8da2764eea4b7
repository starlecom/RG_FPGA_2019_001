/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "sys_intr.h"
#include "platform.h"
#include "dma_intr.h"
#include "timer_intr.h"
#include "gpio_dev.h"
#include "lwip_mod.h"
#include "ps7_init.h"
#include "software_intr.h"
#include "core1_start.h"
#include "xqspips_flash.h"


//#define TIMER_LOAD_VALUE    333333 //1ms
#define TIMER_LOAD_VALUE    9260 //28us

#define NULL_FRAME          1
#define ONLINE_FRAME        2

#define DISCONNECT_PERIOD    (300)

static XScuGic Intc; //GIC
XAxiDma AxiDma;
static  XScuTimer Timer;//timer
//static  XScuWdt Wdt;

u16 *RxBufferPtr[1];  /* ping pong buffers*/

int led_flag=0;
int led=0;
enum tcp_state client_state;


int dma_trans()
{
	while(1)
	{
		if (tmr_send_flag)
		{
			tmr_send_flag=0;
//			gpio_set_chs((1<<0));
//			gpio_set_ch_sel(1<<0);
//			clr_rec_cnt();
			running_flag = 1;
		}

		TcpRecv();

		if(syn_mode_flag)
		{
			syn_mode_flag = 0;
			Gen_Software_Intr(&Intc, CORE0_TO_CORE1_INTR_ID, XSCUGIC_SPI_CPU1_MASK);
		}

		if (TcpFastTmrFlag)
		{
			m_tcp_fasttmr();
			TcpFastTmrFlag = 0;
		}
		if (TcpSlowTmrFlag)
		{
			m_tcp_slowtmr();
			TcpSlowTmrFlag = 0;
		}
		xemacif_input(echo_netif);

		if(tmr_1s_flag)
		{
			tmr_1s_flag = 0;
			if (led_flag > 0)
			{
				led_flag = 0;
				gpio_set_led(0x01);
			}
			else
			{
				led_flag = 1;
				gpio_set_led(0x00);
			}
		}


		DmaReceive();
		/* if connected to the server, start receive data from PL through axidma, then transmit the data to the PC software by TCP*/
		if(running_flag)
		{
			if(tmr_2ms7_flag)
			{
				tmr_2ms7_flag = 0;
				send_received_data();
			}
		}
	}
	return 0;
}

int init_intr_sys(void)
{
	DMA_Intr_Init(&AxiDma,0);//initial interrupt system
	Timer_init(&Timer,TIMER_LOAD_VALUE,0);
	Init_Intr_System(&Intc);
	Setup_Intr_Exception(&Intc);
	DMA_Setup_Intr_System(&Intc,&AxiDma,0,RX_INTR_ID);//setup dma interrupt system
	/*initial software interrupt of local cpu*/
	Init_Software_Intr(&Intc, Cpu0_Intr_Hanedler, CORE1_TO_CORE0_INTR_ID, 0);
	Timer_Setup_Intr_System(&Intc,&Timer,TIMER_IRPT_INTR);
	DMA_Intr_Enable(&Intc,&AxiDma);

	return 0;
}

int main()
{
    init_platform();
    ps7_post_config();

    m_gpio_init();

    qspi_init(XPAR_XQSPIPS_0_DEVICE_ID);
    para_update();

    RxBufferPtr[0] = (u16 *)RX_BUFFER0_BASE;
    shared_mem_init();
    init_intr_sys();
    Timer_start(&Timer);

    Start_cpu1();
    lwip_server_setup(ip4_add);
    dma_trans();

    cleanup_platform();
    return 0;
}
