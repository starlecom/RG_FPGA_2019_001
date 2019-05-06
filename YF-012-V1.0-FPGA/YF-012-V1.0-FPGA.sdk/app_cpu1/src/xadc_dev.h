/*
 *
 * www.osrc.cn
 * www.milinker.com
 * copyright by nan jin mi lian dian zi www.osrc.cn
*/
#if 1
#ifndef X_ADC_H
#define X_ADC_H

#include "xparameters.h"
#include "xadcps.h"
#include "xstatus.h"

#define XADC_DEVICE_ID 		XPAR_XADCPS_0_DEVICE_ID

#define XAdcPs_RawToTemperature(AdcData)				\
	((((float)(AdcData)/65536.0f)/0.00198421639f ) - 273.15f)

int  m_xadc_init(void);
u32 xadc_read_vint(void);
u32 xadc_read_vaux3(void);

#endif

#endif
