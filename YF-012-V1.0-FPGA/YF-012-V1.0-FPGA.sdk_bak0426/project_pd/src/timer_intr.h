/*
 *
 * www.osrc.cn
 * www.milinker.com
 * copyright by nan jin mi lian dian zi www.osrc.cn
*/

#ifndef TIMER_INTR_H_
#define TIMER_INTR_H_

#include <stdio.h>
#include "xadcps.h"
#include "xil_types.h"
#include "Xscugic.h"
#include "Xil_exception.h"
#include "xscutimer.h"
#include "xil_printf.h"
#include "gpio_dev.h"
#include "lwip_mod.h"

#define TIMER_1S      36000
#define TIMER_10S      (10*36000)
#define TIMER_250MS   9000
#define TIMER_1MIN    (TIMER_1S*60)
#define TIMER_ONLINE  (TIMER_1MIN*2)
#define TIMER_1MIN     (TIMER_1S*60)




extern volatile int TcpFastTmrFlag;
extern volatile int TcpSlowTmrFlag;
extern u32 tmr_10s_flag;
extern u16 tmr_1s_flag;
extern u8 tmr_1min_flag;
extern u32 tmr_2ms7_flag;
extern u8 tmr_send_flag;
extern u8 tmr_connect_flag;
extern u8 send_period;

//timer info
#define TIMER_DEVICE_ID     XPAR_XSCUTIMER_0_DEVICE_ID
#define TIMER_IRPT_INTR     XPAR_SCUTIMER_INTR

u8 get_mode_now(void);
void change_mode(u8 data);
void change_speed_time(u16 data);
void Timer_start(XScuTimer *TimerPtr);
void Timer_Setup_Intr_System(XScuGic *GicInstancePtr,XScuTimer *TimerInstancePtr, u16 TimerIntrId);
int Timer_init(XScuTimer *TimerPtr,u32 Load_Value,u32 DeviceId);
#endif /* TIMER_INTR_H_ */
