
/*
 *
 * www.osrc.cn
 * www.milinker.com
 * copyright by nan jin mi lian dian zi www.osrc.cn
*/
#if 1
#include "xadc_dev.h"

static XAdcPs XAdcInst;      /* XADC driver instance */


int  m_xadc_init(void)
{

	int Status;
	XAdcPs_Config *ConfigPtr;
	XAdcPs *XAdcInstPtr = &XAdcInst;

	/*
	 * Initialize the XAdc driver.
	 */
	ConfigPtr = XAdcPs_LookupConfig(XADC_DEVICE_ID);
	if (ConfigPtr == NULL) {
		return XST_FAILURE;
	}
	XAdcPs_CfgInitialize(XAdcInstPtr, ConfigPtr,
				ConfigPtr->BaseAddress);
	
	/*
	 * Self Test the XADC/ADC device
	 */
	Status = XAdcPs_SelfTest(XAdcInstPtr);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Disable the Channel Sequencer before configuring the Sequence
	 * registers.
	 */
//	XAdcPs_SetSequencerMode(XAdcInstPtr, XADCPS_SEQ_MODE_SINGCHAN);
//	XAdcPs_SetAlarmEnables(XAdcInstPtr, 0x0);
//	XAdcPs_SetSequencerMode(XAdcInstPtr, XADCPS_SEQ_MODE_SAFE);
	//configure the channel enables we want to monitor

	XAdcPs_SetAvg(XAdcInstPtr, XADCPS_AVG_0_SAMPLES);
	XAdcPs_SetSeqChEnables(XAdcInstPtr,(XADCPS_CH_AUX_MIN+3));

//	xadc_read_vint();
//	xadc_read_vaux3();


	return 0;
}

u32 xadc_read_vint(void)
{
	u32 TempRawData;
	XAdcPs *XAdcInstPtr = &XAdcInst;
	/*
	 * Read the on-chip Temperature Data (Current/Maximum/Minimum)
	 * from the ADC data registers.
	 */
	TempRawData = XAdcPs_GetAdcData(XAdcInstPtr, XADCPS_CH_VCCINT);
	TempRawData=(u32)(TempRawData*3*100/65536.0);
//	TempData = XAdcPs_RawToTemperature(TempRawData);

	return TempRawData;
}

u32 xadc_read_vaux3(void)
{
	u32 TempRawData;
	XAdcPs *XAdcInstPtr = &XAdcInst;
	/*
	 * Read the on-chip Temperature Data (Current/Maximum/Minimum)
	 * from the ADC data registers.
	 */
	TempRawData = XAdcPs_GetAdcData(XAdcInstPtr, XADCPS_CH_AUX_MIN+3);
	TempRawData=(u32)(TempRawData*1*1000/65536.0);
//	TempData = XAdcPs_RawToTemperature(TempRawData);

	return TempRawData;
}

void xadc_check(void)
{
	XAdcPs *XAdcInstPtr = &XAdcInst;
	u32 status=XAdcPs_GetMiscStatus(XAdcInstPtr);
}

#endif
