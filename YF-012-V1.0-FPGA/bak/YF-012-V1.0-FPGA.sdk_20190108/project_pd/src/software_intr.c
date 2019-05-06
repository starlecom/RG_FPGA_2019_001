/*
 * software_intr.c
 *
 * www.osrc.cn
 * www.milinker.com
 * copyright by nan jin mi lian dian zi www.osrc.cn
*/
#include "software_intr.h"

u8 data_from_cpu1[6];
u8 syn_data[6];

void Cpu0_Intr_Hanedler(void *Callback)
{
	u16 tmp = (data_from_cpu1[4])|(data_from_cpu1[5]<<8);
	get_data_from_region(data_from_cpu1,region);
	memcpy(syn_data ,data_from_cpu1, 6);
	//xil_printf("ampl=%d\r\n",tmp);
}


void Init_Software_Intr(XScuGic *GicInstancePtr, Xil_InterruptHandler IntrHanedler, u16 SoftwareIntrId, u8 CpuId)
{

	int Status;

	XScuGic_SetPriorityTriggerType(GicInstancePtr, SoftwareIntrId, 0xB0, 0x2);

	Status = XScuGic_Connect(GicInstancePtr, SoftwareIntrId,
				 (Xil_InterruptHandler)IntrHanedler, NULL);
	if (Status != XST_SUCCESS) {
//		xil_printf("core%d: interrupt %d set fail!\r\n", XPAR_CPU_ID, SoftwareIntrId);
		return;
	}

	XScuGic_InterruptMaptoCpu(GicInstancePtr, CpuId, SoftwareIntrId); //map the the Software interrupt to target CPU

	XScuGic_Enable(GicInstancePtr, SoftwareIntrId);//enable the interrupt for the Software interrupt at GIC
 }


void Gen_Software_Intr(XScuGic *GicInstancePtr, u16 SoftwareIntrId, u32 CpuId)
{
	int Status;

	Status = XScuGic_SoftwareIntr(GicInstancePtr, SoftwareIntrId, CpuId);
	if (Status != XST_SUCCESS) {
//		xil_printf("core%d: interrupt %d gen fail!\r\n", XPAR_CPU_ID, SoftwareIntrId);
		return;
	}
}

