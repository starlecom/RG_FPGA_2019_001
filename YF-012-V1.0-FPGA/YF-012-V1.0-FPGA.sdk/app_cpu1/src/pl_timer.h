/*
 * pl_timer.h
 *
 *  Created on: 2017Äê11ÔÂ27ÈÕ
 *      Author: Administrator
 */

#ifndef PL_TIMER_H_
#define PL_TIMER_H_
#include <stdio.h>
#include "xscugic.h"
#include "xil_exception.h"
#include "xadcps.h"
#include "xil_types.h"
#include "Xscugic.h"
#include "Xil_exception.h"
#include "xil_printf.h"
#include "xadc_dev.h"
#include "fdacoefs.h"
#include "shared_mem.h"
#include "software_intr.h"

#define PL_TMR_INTR_ID          31
#define SYN_O_MODE              0x00
#define SYN_I_MODE              0x01
#define PHASE_OFFSET            390

#define SYN_ADJUST_PERIOD    (1000)
#define SYN_PERIOD    (15*100*1000)

#define MAX(a,b)     (((a)>(b))?(a):(b))
#define MIN(a,b)     (((a)<(b))?(a):(b))

extern u8 data_save_flag;
extern volatile u8 pl_tmr_10us_flag;
extern void GetLFData(u32 *arr);
void PL_Timer_IntcInit(XScuGic *GicInstancePtr,  u16 SoftwareIntrId, u8 CpuId);
void syn_process(void);
void timer_10us_process(void);
void set_syn_mode(u8 mode);   //SYN_O_MODE : 0x00  SYN_I_MODE : 0x01
void set_syn_i_del(u16 fre);  //0.1hz
void set_frequency_i(u16 data);
#endif /* PL_TIMER_H_ */
