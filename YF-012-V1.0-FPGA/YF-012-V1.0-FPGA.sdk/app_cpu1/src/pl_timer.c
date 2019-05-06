/*
 * pl_timer.c
 *
 *  Created on: 2017年11月27日
 *      Author: Administrator
 */
#include "pl_timer.h"

#define INT_CFG0_OFFSET 0x00000C00

// Parameter definitions
#define INTC_DEVICE_ID          XPAR_PS7_SCUGIC_0_DEVICE_ID
#define INT_TYPE_RISING_EDGE    0x03
#define INT_TYPE_HIGHLEVEL      0x01
#define INT_TYPE_MASK           0x03

static u16 lf_ampl=0;
static u16 lf_frequency=0;
static u16 lf_period=0;
static int syn_flag=0;   //syn step
static u32 syn_adjust_cnt=0;
static u32 syn_cnt=0;
static u32 lf_data[LF_DATA_SIZE];    //xadc data
static u32 lf_data_out[LF_DATA_SIZE];//filtered data
static u32 lf_peak_tmp[4];           //max period frequency
static u32 lf_peak=0;
static u32 lf_aver=0;
volatile u8 pl_tmr_save_flag=0;      //timer flag(20us) for sending data to cpu0
volatile u8 pl_tmr_10us_flag=0;
volatile u8 pl_tmr_20us_flag=0;
static float phase_pos_o=1000;
static float phase_pos_i=0;
static u16 phase_pos=1000;
static u8 syn_success_flag=0;
static volatile u8 syn_select = 0;
u8 data_save_flag=0;
static u32 delay_cnt = 0;
//static int led = 0;
static u32 phase_buf[21];//测试相位
static u16 timer_syn_cnt = 0;
static u16 timer_save_cnt = 0;
static float phase_del_o=0;
static float phase_del_i=0;
static void Timer_10us_intr_Handler(void *param);
static void start_syn_o_timer(void);

void set_syn_mode(u8 mode)
{
	syn_select = mode;
}

static void SetPhasePos(float data)
{
	phase_pos = (u16)data;
}

static u16 GetPhasePos(void)
{
	return (u16)phase_pos;
}

static u16 GetAmpl(void)
{
	return (u16)lf_ampl;
}

static void SetAmpl(u16 data)   //需要转换成实际值
{
	float tmp = 0;
	if(data < 516)
	{
		lf_ampl = 0;
	}
	else
	{
		tmp = (float)(5405*data - 2773000)/100;
		lf_ampl = (u16) tmp;
	}
}

void set_frequency_i(u16 data)
{
	lf_frequency = data;
}

static u16 GetFrequency(void)
{
	return lf_frequency;
}

static void FindMax(u32 *arr, u32 *result)
{
    u32 max = 0;
    u16 i = 0;
    u16 m_index1 = 0;
    u16 m_index2 = 0;
    u32 sum=0;
    u32 aver = 0;
    for(i = 0 ; (i != (LF_DATA_SIZE-ORDER)) ; i++)
    {
    	sum += arr[i];
        if(max < arr[i])
        {
            max = arr[i];
            m_index1 = i;
        }
        else if(max == arr[i])
        {
        	if((i > (m_index1 + 1600))&&(i < (m_index1 + 2500))&&(i > (m_index2 + 1600)))
        	{
        		m_index2 = i;
        	}
        }
    }
    aver = sum / (LF_DATA_SIZE-ORDER);
    result[3] = aver;
    result[0] = max;
    if(m_index2 > m_index1)
    {
    	result[2]= m_index2 - m_index1;
    	result[1] = 1000000/result[2];
    	if((result[1] < 480)||(result[1] > 520)||(result[0] - aver <= 2))  // frequency:48hz-52hz  max > aver+2
    	{
    		result[2] = 0;
    		result[1] = 0;
    		result[0] = 0;
    	}
    }
    else
    {
    	result[2] = 0;
    	result[1] = 0;
    	result[0] = 0;
    }
}

static void set_syn_o_del(u16 period)
{
	float tmp = 0;
	if(!period)
	{
		phase_del_o = 0;
	}
	else
	{
		tmp = (float)720*20/(period*10);    //20us phase_pos delta
		phase_del_o = tmp;
	}

}


void set_syn_i_del(u16 fre)  //0.1hz
{
	float tmp = 0;
	if(!fre)
	{
		phase_del_o = 0;
	}
	else
	{
		tmp = (float)720*20*fre/10000000;    //20us phase_pos delta
		phase_del_i = tmp;
	}
}

static void timer_datasave(void)
{
	u8 buffer[6];
	u16 phase_tmp = GetPhasePos();
	u16 fre_tmp   = GetFrequency();
	u16 ampl_tmp = GetAmpl();
	if(pl_tmr_save_flag)
	{
		pl_tmr_save_flag = 0;

		buffer[0] = (u8)phase_tmp;
		buffer[1] = (u8)(phase_tmp>>8);
		buffer[2] = (u8)fre_tmp;
		buffer[3] = (u8)(fre_tmp>>8);
		buffer[4] = (u8)ampl_tmp;
		buffer[5] = (u8)(ampl_tmp>>8);
		put_data_to_region(buffer,data_to_cpu0,6,region);
		data_save_flag = 1;
	}
}

static void start_syn_i_timer(void)
{
	if((pl_tmr_20us_flag & (1<<1)))
	{
		pl_tmr_20us_flag &= ~(1<<1);

		phase_pos_i += phase_del_i;;
		if(phase_pos_i > 720)
		{
			phase_pos_i = 0;
		}

	}
}

void syn_adjust(void)
{
	static u8 step = 0;
	static u32 aver_tmp[8] = {0};
	float average[2]={0};
	if(delay_cnt)
	{
		delay_cnt = 0;
		switch(step)
		{
		case 0: aver_tmp[0] = xadc_read_vaux3();
				step++;
		        break;
		case 1: aver_tmp[1] = xadc_read_vaux3();
				step++;
		        break;
		case 2: aver_tmp[2] = xadc_read_vaux3();
			    step++;
			    break;
		case 3: aver_tmp[3] = xadc_read_vaux3();
				step++;
		        break;
		case 4: aver_tmp[4] = xadc_read_vaux3();
			    step++;
			    break;
		case 5: aver_tmp[5] = xadc_read_vaux3();
				average[0] = (float)(aver_tmp[0]+aver_tmp[1]+aver_tmp[2])/3;
				average[1] = (float)(aver_tmp[3]+aver_tmp[4]+aver_tmp[5])/3;
		        if((average[0] < lf_aver)&&(average[1] > lf_aver))
		        {
		        	syn_success_flag = 1;
		        	phase_pos_o      = PHASE_OFFSET;
					//syn_flag         = 10;
		        }
				step = 0;
		        memset(aver_tmp,0,6);
			    break;
		default:break;
		}
	}
}


void syn_process(void)
{
	static u16 j=0;
	static u16 no_syn_cnt=0;
	static u8 syn_select_bk=0;
	switch(syn_flag)
	{
		case 0:
			phase_pos_o  = 1000;
			break;
		case 1:
			filter(lf_data,lf_data_out);
			FindMax(lf_data_out,lf_peak_tmp);
			if(lf_peak_tmp[1] == 0)
			{
				syn_flag = 0;                           //restart syn
				no_syn_cnt++;
				if(no_syn_cnt > 20)                    //if syn has been over 20 times,no syn signal will be confirmed.
				{
					syn_flag = 0;
					no_syn_cnt = 20;
					SetAmpl((u16)lf_peak_tmp[0]);
					lf_frequency = (u16)lf_peak_tmp[1];
					lf_period = (u16)lf_peak_tmp[2];
				}
//				xil_printf("\n\r----No SYN Signal----\n\r");
			}
			else
			{
				no_syn_cnt = 0;
				SetAmpl((u16)lf_peak_tmp[0]);
				lf_frequency = (u16)lf_peak_tmp[1];
				lf_period = (u16)lf_peak_tmp[2];
				lf_aver = (u16)lf_peak_tmp[3];
				set_syn_o_del(lf_period);
//				xil_printf("\n\rlf_ampl=%d\n\r",lf_peak_tmp[0]);
//				xil_printf("\n\rpeak_frequency=%d\n\r",lf_frequency);
				syn_flag ++;
			}
			break;
		case 2:
			syn_adjust();
			break;
//		case 10:
//			if(j < (LF_DATA_SIZE-ORDER))
//			{
//				//xil_printf("%d, \n\r",(u32)lf_data_out[j]);
//				j++;
//			}
//			else
//			{
//				xil_printf("\n\r----SYN End----\n\r");
//				syn_flag = 2;
//			}
//			break;
		default : break;
	}

	if(syn_select_bk != syn_select)    //if syn_mode is changed,phase position will be reinitialized.
	{
		syn_select_bk = syn_select;
		phase_pos = 0;
		phase_pos_i = 0;
		phase_pos_o = 1000;
		syn_flag = 0;
	}

    if(syn_select==SYN_O_MODE)
    {
    	SetPhasePos(phase_pos_o);
		if(syn_success_flag)
		{
			start_syn_o_timer();
		}
    }
	else if(syn_select==SYN_I_MODE)
	{
		syn_flag = 11;
		SetPhasePos(phase_pos_i);
		start_syn_i_timer();
	}

	timer_datasave();
}

static void start_syn_o_timer(void)
{
	if((pl_tmr_20us_flag&0x01))
	{
		pl_tmr_20us_flag &= 0xfe;
		if(phase_pos_o!=1000)
		{
			phase_pos_o += phase_del_o;;
			if(phase_pos_o >= 720)
			{
				phase_pos_o -= 720;
			}
		}
	}
}



void timer_10us_process(void)
{
	static u16 i=0;
	if(pl_tmr_10us_flag)
	{
		pl_tmr_10us_flag = 0;
		if(syn_flag == 0)          //采集两周期波形
		{
			lf_data[i] = xadc_read_vaux3();
			i++;
			if(i >= LF_DATA_SIZE)
			{
				i        = 0;
				syn_flag = 1;
			}
		}

		if(syn_select == SYN_O_MODE)
		{
			syn_adjust_cnt++;
			syn_cnt++;
			if(syn_adjust_cnt > SYN_ADJUST_PERIOD)
			{
				if((lf_frequency >= 480)&&(lf_frequency <= 520))
				{
					//syn_flag =0;

				}
				else
				{
					syn_flag = 0;
				}

				syn_adjust_cnt = 0;
			}

			if(syn_cnt > SYN_PERIOD)
			{
				syn_flag = 0;
				syn_cnt = 0;
			}
		}

		timer_syn_cnt++;
		if(timer_syn_cnt >= 2)
		{
			timer_syn_cnt = 0 ;
			pl_tmr_20us_flag = 0xff;
		}

		timer_save_cnt++;
		if(timer_save_cnt >= 1)
		{
			timer_save_cnt   = 0;
			pl_tmr_save_flag = 1;
		}
	}
}

static void Timer_10us_intr_Handler(void *param)
{
	pl_tmr_10us_flag = 1;
	delay_cnt = 1;
}

void IntcTypeSetup(XScuGic *InstancePtr, int intId, int intType)
{
    int mask;

    intType &= INT_TYPE_MASK;
    mask = XScuGic_DistReadReg(InstancePtr, INT_CFG0_OFFSET + (intId/16)*4);
    mask &= ~(INT_TYPE_MASK << (intId%16)*2);
    mask |= intType << ((intId%16)*2);
    XScuGic_DistWriteReg(InstancePtr, INT_CFG0_OFFSET + (intId/16)*4, mask);
}


void PL_Timer_IntcInit(XScuGic *GicInstancePtr,  u16 SoftwareIntrId, u8 CpuId)
{

	int Status;

	XScuGic_SetPriorityTriggerType(GicInstancePtr, SoftwareIntrId, 0x08, 0x3);

	Status = XScuGic_Connect(GicInstancePtr, SoftwareIntrId,
				 (Xil_InterruptHandler)Timer_10us_intr_Handler, NULL);
	if (Status != XST_SUCCESS) {
//		xil_printf("core%d: interrupt %d set fail!\r\n", XPAR_CPU_ID, SoftwareIntrId);
		return;
	}

	//XScuGic_InterruptMaptoCpu(GicInstancePtr, CpuId, SoftwareIntrId); //map the the Software interrupt to target CPU

	XScuGic_Enable(GicInstancePtr, SoftwareIntrId);//enable the interrupt for the Software interrupt at GIC
 }

