/*
 * xqspips_flash.h
 *
 *  Created on: 2018Äê2ÔÂ8ÈÕ
 *      Author: Administrator
 */

#ifndef XQSPIPS_FLASH_H_
#define XQSPIPS_FLASH_H_

#include "xparameters.h"	/* SDK generated parameters */
#include "xqspips.h"		/* QSPI device driver */
#include "xil_printf.h"
#include "gpio_dev.h"
#include "timer_intr.h"

#define QSPI_DEVICE_ID		XPAR_XQSPIPS_0_DEVICE_ID
/*
 * Flash address to which data is ot be written.
 */
#define PARA_ADDR		0x01FF0000   //last sector (size : 64kb)

#define ADJUSTED_ADDR       0
#define COE_ADDR            1
#define OFFSET_ADDR         2
#define ID_ADDR             3
#define SAM_PER_ADDR        4
#define IP_ADDR       		5
#define TRI_H_1_ADDR    	6
#define TRI_L_1_ADDR    	7
#define TRI_H_2_ADDR    	8
#define TRI_L_2_ADDR    	9
#define TRI_H_3_ADDR    	10
#define TRI_L_3_ADDR    	11
#define CENTER_1_ADDR		12
#define CENTER_2_ADDR		13
#define CENTER_3_ADDR		14



extern u32 flash_data[64];

extern int qspi_init(u16 QspiDeviceId);
extern u32 qspi_read(u32 Address);
extern void qspi_write(u32 Address);
extern void para_update(void);

#endif /* XQSPIPS_FLASH_H_ */
