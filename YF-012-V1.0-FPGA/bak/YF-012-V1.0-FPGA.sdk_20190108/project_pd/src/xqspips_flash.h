/*
 * xqspips_flash.h
 *
 *  Created on: 2018��2��8��
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



extern u32 flash_data[6];

extern int qspi_init(u16 QspiDeviceId);
extern u32 qspi_read(u32 Address);
extern void qspi_write(u32 Address);
extern void para_update(void);

#endif /* XQSPIPS_FLASH_H_ */