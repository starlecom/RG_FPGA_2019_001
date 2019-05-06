
/*
 *
 * www.osrc.cn
 * www.milinker.com
 * copyright by nan jin mi lian dian zi www.osrc.cn
*/
#include "dma_intr.h"

volatile int TxDone;
volatile int RxDone;
volatile int Error;
int time_out;

/*****************************************************************************/
/**
*
* This function disables the interrupts for DMA engine.
*
* @param	IntcInstancePtr is the pointer to the INTC component instance
* @param	TxIntrId is interrupt ID associated w/ DMA TX channel
* @param	RxIntrId is interrupt ID associated w/ DMA RX channel
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
 void DMA_DisableIntrSystem(XScuGic * IntcInstancePtr,
					u16 TxIntrId, u16 RxIntrId)
{
#ifdef XPAR_INTC_0_DEVICE_ID
	/* Disconnect the interrupts for the DMA TX and RX channels */
	XIntc_Disconnect(IntcInstancePtr, TxIntrId);
	XIntc_Disconnect(IntcInstancePtr, RxIntrId);
#else
	XScuGic_Disconnect(IntcInstancePtr, TxIntrId);
	XScuGic_Disconnect(IntcInstancePtr, RxIntrId);
#endif
}



/*****************************************************************************/
/*
*
* This is the DMA RX interrupt handler function
*
* It gets the interrupt status from the hardware, acknowledges it, and if any
* error happens, it resets the hardware. Otherwise, if a completion interrupt
* is present, then it sets the RxDone flag.
*
* @param	Callback is a pointer to RX channel of the DMA engine.
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
static void DMA_RxIntrHandler(void *Callback)
{
	u32 IrqStatus;
	int Status;
//	int TimeOut;
	XAxiDma *AxiDmaInst = (XAxiDma *)Callback;

	//xil_printf("Enter interrupt !\r\n");
	/* Read pending interrupts */
//	IrqStatus = XAxiDma_IntrGetIrq(AxiDmaInst, XAXIDMA_DEVICE_TO_DMA);
	IrqStatus = XAxiDma_ReadReg(AxiDmaInst->RegBase + (XAXIDMA_RX_OFFSET * XAXIDMA_DEVICE_TO_DMA), XAXIDMA_SR_OFFSET);

	/* Acknowledge pending interrupts */
	XAxiDma_IntrAckIrq(AxiDmaInst, IrqStatus, XAXIDMA_DEVICE_TO_DMA);
//	xil_printf("Enter DMA_RxIntrHandler\r\n");
	/*
	 * If no interrupt is asserted, we do not do anything
	 */
	if (!(IrqStatus & XAXIDMA_IRQ_ALL_MASK)) {
//		xil_printf("no interrupt is asserted\r\n");
		return;
	}

	/*
	 * If error interrupt is asserted, raise error flag, reset the
	 * hardware to recover from the error, and return with no further
	 * processing.
	 */
	if ((IrqStatus & XAXIDMA_IRQ_ERROR_MASK)) {
		XAxiDma_Reset(AxiDmaInst);
		time_out = RESET_TIMEOUT_COUNTER;
		while(time_out)
		{
			if(XAxiDma_ResetIsDone(AxiDmaInst)){
				break;
			}
			time_out--;
		}
		DMA_Intr_Enable(AxiDmaInst);
		Status = XAxiDma_SimpleTransfer(AxiDmaInst, (u32)RxBufferPtr[0],(u32)(PAKET_LENGTH), XAXIDMA_DEVICE_TO_DMA);
		xil_printf("Error:0x%x dma from device %d \n", IrqStatus,time_out);
		xil_printf(" Status = %d \n", Status);
//		return;
	}

	/*
	 * If completion interrupt is asserted, then set RxDone flag
	 */
	if ((IrqStatus & XAXIDMA_IRQ_IOC_MASK)) {

		if(packet_trans_done)
		{
			xil_printf("last transmission has not finished!\r\n");
		}
		else
		{
			/*set the axidma done flag*/
			packet_trans_done=1;
			Xil_DCacheInvalidateRange(RX_BUFFER0_BASE,(u32)(PAKET_LENGTH));
		}
	}
}

/*****************************************************************************/
/*
*
* This function setups the interrupt system so interrupts can occur for the
* DMA, it assumes INTC component exists in the hardware system.
*
* @param	IntcInstancePtr is a pointer to the instance of the INTC.
* @param	AxiDmaPtr is a pointer to the instance of the DMA engine
* @param	TxIntrId is the TX channel Interrupt ID.
* @param	RxIntrId is the RX channel Interrupt ID.
*
* @return
*		- XST_SUCCESS if successful,
*		- XST_FAILURE.if not succesful
*
* @note		None.
*
******************************************************************************/
int DMA_Setup_Intr_System(XScuGic * IntcInstancePtr,XAxiDma * AxiDmaPtr, u16 TxIntrId, u16 RxIntrId)
{
	int Status;
	XScuGic_SetPriorityTriggerType(IntcInstancePtr, RxIntrId, 0xA0, 0x3);

	//XScuGic_SetPriorityTriggerType(IntcInstancePtr, RxIntrId, 0xA0, 0x3);
	/*
	 * Connect the device driver handler that will be called when an
	 * interrupt for the device occurs, the handler defined above performs
	 * the specific interrupt processing for the device.
	 */
//	Status = XScuGic_Connect(IntcInstancePtr, TxIntrId,
//				(Xil_InterruptHandler)Timer_1us_intr_Handler,
//				AxiDmaPtr);
//	if (Status != XST_SUCCESS) {
//		return Status;
//	}

	Status = XScuGic_Connect(IntcInstancePtr, RxIntrId,
				(Xil_InterruptHandler)DMA_RxIntrHandler,
				AxiDmaPtr);
	if (Status != XST_SUCCESS) {
		return Status;
	}

//	XScuGic_Enable(IntcInstancePtr, TxIntrId);
	XScuGic_Enable(IntcInstancePtr, RxIntrId);
	return XST_SUCCESS;
}


int DMA_Intr_Enable(XAxiDma *DMAPtr)
{

	/* Disable all interrupts before setup */

	XAxiDma_IntrDisable(DMAPtr, XAXIDMA_IRQ_ALL_MASK,
						XAXIDMA_DMA_TO_DEVICE);

	XAxiDma_IntrDisable(DMAPtr, XAXIDMA_IRQ_ALL_MASK,
				XAXIDMA_DEVICE_TO_DMA);

	/* Enable all interrupts */
	XAxiDma_IntrEnable(DMAPtr, XAXIDMA_IRQ_ALL_MASK,
							XAXIDMA_DMA_TO_DEVICE);

	XAxiDma_IntrEnable(DMAPtr, XAXIDMA_IRQ_ALL_MASK,
							XAXIDMA_DEVICE_TO_DMA);
	return XST_SUCCESS;

}


int DMA_Intr_Init(XAxiDma *DMAPtr,u32 DeviceId)
{
	int Status;
	XAxiDma_Config *Config=NULL;

	Config = XAxiDma_LookupConfig(DeviceId);
	if (!Config) {
		xil_printf("No config found for %d\r\n", DeviceId);
		return XST_FAILURE;
	}

	/* Initialize DMA engine */
	Status = XAxiDma_CfgInitialize(DMAPtr, Config);

	if (Status != XST_SUCCESS) {
		xil_printf("Initialization failed %d\r\n", Status);
		return XST_FAILURE;
	}

	if(XAxiDma_HasSg(DMAPtr)){
		xil_printf("Device configured as SG mode \r\n");
		return XST_FAILURE;
	}

//	Xil_DCacheDisable();		//��ֹCACHE�������ڴ����ݲ�����

	return XST_SUCCESS;

}
