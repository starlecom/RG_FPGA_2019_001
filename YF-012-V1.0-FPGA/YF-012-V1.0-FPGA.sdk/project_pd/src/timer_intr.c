/*
 *
 * www.osrc.cn
 * www.milinker.com
 * copyright by nan jin mi lian dian zi www.osrc.cn
*/

#include "timer_intr.h"

volatile int TcpFastTmrFlag = 0;
volatile int TcpSlowTmrFlag = 0;
int tmr_cnt=0;
int tmr_2ms7_cnt=0;
u32 tmr_10s_flag_cnt=0;
u32 tmr_10s_flag=0;
u16 tmr_1s_cnt=0;
u16 tmr_1s_flag=0;
u32 tmr_1min_cnt=0;
u8 tmr_1min_flag=0;
u32 tmr_2ms7_flag=0;
u8 tmr_send_flag=0;
u8 tmr_connect_flag = 0;
u32 tmr_send_cnt=0;
u32 tmr_online_cnt=0;
u8  tmr_online_flag = 0;
u8 send_period = 1;

static u16 speed_time = 72;

static void TimerIntrHandler(void *CallBackRef)
{
    XScuTimer *TimerInstancePtr = (XScuTimer *) CallBackRef;
    XScuTimer_ClearInterruptStatus(TimerInstancePtr);

	if (tmr_10s_flag_cnt < TIMER_10S)
	{
		tmr_10s_flag_cnt++;
	}
	else
	{
		tmr_10s_flag_cnt = 0;
		tmr_10s_flag     = 1;
	}

    if (tmr_cnt < TIMER_250MS)
    {
    	tmr_cnt++;
    }
    else
    {
    	tmr_cnt = 0;
    	TcpFastTmrFlag = 1;
    	TcpSlowTmrFlag = 1;
    }

    if (tmr_2ms7_cnt < speed_time)
    {
    	tmr_2ms7_cnt++;
    }
    else
    {
    	tmr_2ms7_cnt = 0;
    	tmr_2ms7_flag++;
    }

    if (tmr_1s_cnt < TIMER_1S)
    {
        tmr_1s_cnt++;
    }
    else
    {
    	tmr_1s_cnt = 0;
        tmr_1s_flag++;
    }

    if (tmr_send_cnt < TIMER_ONLINE)
	{
    	tmr_send_cnt++;
	}
	else
	{
		tmr_send_cnt = 0;
		tmr_connect_flag++;
	}

    if (tmr_1min_cnt < TIMER_1MIN)
	{
		tmr_1min_cnt++;
	}
	else
	{
		tmr_1min_cnt = 0;
		tmr_1min_flag++;
	}

}

void Timer_start(XScuTimer *TimerPtr)
{
	    XScuTimer_Start(TimerPtr);
}

void Timer_Setup_Intr_System(XScuGic *GicInstancePtr,XScuTimer *TimerInstancePtr, u16 TimerIntrId)
{
        XScuGic_Connect(GicInstancePtr, TimerIntrId,
                        (Xil_ExceptionHandler)TimerIntrHandler,//set up the timer interrupt
                        (void *)TimerInstancePtr);

        XScuGic_Enable(GicInstancePtr, TimerIntrId);//enable the interrupt for the Timer at GIC
        XScuTimer_EnableInterrupt(TimerInstancePtr);//enable interrupt on the timer
 }

int Timer_init(XScuTimer *TimerPtr,u32 Load_Value,u32 DeviceId)
{
     XScuTimer_Config *TMRConfigPtr;     //timer config
     //私有定时器初始化
     TMRConfigPtr = XScuTimer_LookupConfig(DeviceId);
     XScuTimer_CfgInitialize(TimerPtr, TMRConfigPtr,TMRConfigPtr->BaseAddr);
     //XScuTimer_SelfTest(&Timer);
     //加载计数周期，私有定时器的时钟为CPU的一半，为333MHZ,如果计数1S,加载值为1sx(333x1000x1000)(1/s)-1=0x13D92D3F
     XScuTimer_LoadTimer(TimerPtr, Load_Value);//F8F00600+0=reg=F8F00600
     //自动装载
     XScuTimer_EnableAutoReload(TimerPtr);//F8F00600+8=reg=F8F00608

     return 1;
}
