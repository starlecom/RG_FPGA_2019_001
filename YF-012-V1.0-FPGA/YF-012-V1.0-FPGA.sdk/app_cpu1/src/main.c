/*
 * main.c
 *
 *  Created on: 2017Äê2ÔÂ7ÈÕ
 * www.osrc.cn
 * www.milinker.com
 * copyright by nan jin mi lian dian zi www.osrc.cn
*/


#include "sys_intr.h"
#include "xil_cache.h"
#include "xparameters.h"
#include "software_intr.h"
#include "shared_mem.h"
#include "sleep.h"
#include "pl_timer.h"



XScuGic Intc; //GIC

volatile u8 software_intr_received = 0;

void init_intr_sys(void)
{
	Init_Intr_System(&Intc); // initial interrupt system

	/*initial software interrupt of local cpu*/

	Init_Software_Intr(&Intc, Cpu1_Intr_Hanedler, CORE0_TO_CORE1_INTR_ID, 1);

	PL_Timer_IntcInit(&Intc, PL_TMR_INTR_ID, 1);
	Setup_Intr_Exception(&Intc);
}



int main(void)
{
	u16 fre_tmp=0;
	shared_mem_init();
	m_xadc_init();
	init_intr_sys();

//	xil_printf("core%d: application start\r\n", XPAR_CPU_ID);
	while(1)
	{
		timer_10us_process();
		syn_process();
		if(data_save_flag)
		{
			Gen_Software_Intr(&Intc, CORE1_TO_CORE0_INTR_ID, XSCUGIC_SPI_CPU0_MASK);

			/*clear the interrupt flag*/
			data_save_flag = 0;
		}

		if(software_intr_received)
		{
			software_intr_received = 0;
			get_data_from_region(data_from_cpu0,region_cpu0);
			fre_tmp = data_from_cpu0[1]|(data_from_cpu0[2]<<8);
//			xil_printf("fre_tmp=%d\n\r",fre_tmp);
//			xil_printf("syn_mode=%d\n\r",data_from_cpu0[0]);
			set_syn_mode(data_from_cpu0[0]);
			set_syn_i_del(fre_tmp);
			set_frequency_i(fre_tmp);
		}
	}
}
