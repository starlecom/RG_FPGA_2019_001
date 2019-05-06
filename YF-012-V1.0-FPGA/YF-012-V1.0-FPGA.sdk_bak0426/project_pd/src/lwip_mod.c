
/*
 *
 * www.osrc.cn
 * www.milinker.com
 * copyright by nan jin mi lian dian zi www.osrc.cn
*/
#include "lwip_mod.h"


#define REC_BUF_SIZE 64

//struct netif *netif, server_netif;
static struct tcp_pcb *connected_pcb=NULL;
static int tcp_trans_done=0;
int tcp_recv_cnt=0;
int packet_trans_done = 0;
u8 dma_trans_flag=0;
u16 tmr_disconnect_cnt = 0;
u8 first_packet_flag=1;
u8 syn_mode_flag=0;
extern u16 *RxBufferPtr[1];  /* ping pong buffers*/
static u8 lwip_rec_buf[REC_BUF_SIZE];
static u8 tcp_recv_flag=0;
static u8 sample_buf[3*SEND_SIZE*DMA_REC_SIZE];
static u8 receive_buf1[SEND_SIZE*DMA_REC_SIZE];
static u8 receive_buf2[SEND_SIZE*DMA_REC_SIZE];
static u16 rec_buf1_cnt=0;
static u16 rec_buf2_cnt=0;
static u8 switch_rec_flag=1;
static u8 rec_flag1=0;
static u8 rec_flag2=0;
static u16 send_cnt = 0;
u16 sample_quantity = 2000;
u16 sample_quantity_n = 2000;
u8 send_flag=0;
u8 ch_now = 0;
u16 sample_time = 120;
u8  ip4_add = 10;
u8  running_flag = 0;   //系统工作标志
u8 ch1_cnt = 0;      //抛弃第一次采集的数据

int aver_ch[3] = {0};

static struct netif server_netif;
struct netif *echo_netif;

void send_flashdata(void);

void clr_rec_cnt(void)
{
	switch_rec_flag = 0;
	rec_flag1 = 0;
	rec_flag2 = 0;
	rec_buf1_cnt = 0;
	rec_buf2_cnt = 0;
	memset(receive_buf1,0,SEND_SIZE*DMA_REC_SIZE);
	memset(receive_buf2,0,SEND_SIZE*DMA_REC_SIZE);
	memset(sample_buf,0,3*SEND_SIZE*DMA_REC_SIZE);
	send_flag = 0;
}

void reset_rec_data(void)
{
	memset(receive_buf1,0,SEND_SIZE*DMA_REC_SIZE);
	memset(receive_buf2,0,SEND_SIZE*DMA_REC_SIZE);
	memset(sample_buf,0,3*SEND_SIZE*DMA_REC_SIZE);
	rec_buf1_cnt = 0;
	rec_buf2_cnt = 0;
	switch_rec_flag = 0;
	rec_flag1 = 0;
	rec_flag2 = 0;
	rec_buf1_cnt = 0;
	rec_buf2_cnt = 0;
}

void TcpRecv(void)
{
	u32 data32 = 0;
	u16 data16 = 0;
	u16 data16_2 = 0;
	u16 data16_3 = 0;
	u8 keyword = 0;
	u16 tri_h[3] = {0};
	u16 tri_l[3] = {0};
	u8 ch = 0;
	if(tcp_recv_flag > 0)
	{
		tcp_recv_flag = 0;
		tmr_disconnect_cnt = 0;
		if((lwip_rec_buf[0]==0xa8)&&(lwip_rec_buf[1]==(u8)flash_data[ID_ADDR])&&(lwip_rec_buf[7]==0x78))
		{
			//解析命令
			data32  = (lwip_rec_buf[6]<<24)|(lwip_rec_buf[5]<<16)|(lwip_rec_buf[4]<<8)|lwip_rec_buf[3];
			data16  = (lwip_rec_buf[4]<<8)|lwip_rec_buf[3];
			data16_2= (lwip_rec_buf[6]<<8)|lwip_rec_buf[5];
			data16_3= (lwip_rec_buf[5]<<8)|lwip_rec_buf[4];
			keyword = lwip_rec_buf[2];
			ch = lwip_rec_buf[3];
			memset(lwip_rec_buf,0,8);
			switch(keyword)
			{
				case 0x01:
					if(ch == 0x01)
					{
						flash_data[CENTER_1_ADDR] = (u32) data16_3;
					}
					else if(ch == 0x02)
					{
						flash_data[CENTER_2_ADDR] = (u32) data16_3;
					}
					else if(ch == 0x03)
					{
						flash_data[CENTER_3_ADDR] = (u32) data16_3;
					}
					qspi_init(XPAR_XQSPIPS_0_DEVICE_ID);
					qspi_write(PARA_ADDR);
					para_update();
					break;
				case 0x02:
					if((data16!=sample_quantity)&&(data16 <= DMA_REC_SIZE)&&(data16 >= 1))
					{
						if(!send_flag)
						{
							sample_quantity = data16;
							gpio_set_chs((1<<0));
							gpio_set_ch_sel(1<<0);
							reset_rec_data();
						}
						else
						{
							sample_quantity_n = data16;
						}
					}
					break;
				case 0x03:
					flash_data[COE_ADDR] = (u32) data16;
					qspi_init(XPAR_XQSPIPS_0_DEVICE_ID);
					qspi_write(PARA_ADDR);
					para_update();
					break;
				case 0x04:
					flash_data[OFFSET_ADDR] = data32;
					qspi_init(XPAR_XQSPIPS_0_DEVICE_ID);
					qspi_write(PARA_ADDR);
					para_update();
					break;
				case 0x05:
					flash_data[ID_ADDR] = (u32) data16;
					qspi_init(XPAR_XQSPIPS_0_DEVICE_ID);
					qspi_write(PARA_ADDR);
					para_update();
					break;
				case 0x06:
					flash_data[SAM_PER_ADDR] = (u32) data16;
					qspi_init(XPAR_XQSPIPS_0_DEVICE_ID);
					qspi_write(PARA_ADDR);
					para_update();
					break;
				case 0x07:
					flash_data[IP_ADDR] = (u32) data16;
					if((((u8)flash_data[IP_ADDR]) > 1)&&(((u8)flash_data[IP_ADDR]) != 101))
					{
//						ip4_add = (u8) flash_data[IP_ADDR];
//						lwip_setup(ip4_add);
						qspi_init(XPAR_XQSPIPS_0_DEVICE_ID);
						qspi_write(PARA_ADDR);
						para_update();
					}

					break;
				case 0x08:
					sample_time = data16;
					break;
				case 0x09:
					tmr_send_flag = 1;
					break;
				case 0x10:
					send_flashdata();
					break;
				case 0x11:
					tri_h[0] = data16;
					tri_l[0] = data16_2;

					flash_data[TRI_H_1_ADDR] = (u32) tri_h[0];
					flash_data[TRI_L_1_ADDR] = (u32) tri_l[0];
					qspi_init(XPAR_XQSPIPS_0_DEVICE_ID);
					qspi_write(PARA_ADDR);
					para_update();
					clr_rec_cnt();
					break;
				case 0x12:
					tri_h[1] = data16;
					tri_l[1] = data16_2;

					flash_data[TRI_H_2_ADDR] = (u32) tri_h[1];
					flash_data[TRI_L_2_ADDR] = (u32) tri_l[1];
					qspi_init(XPAR_XQSPIPS_0_DEVICE_ID);
					qspi_write(PARA_ADDR);
					para_update();
					clr_rec_cnt();
					break;
				case 0x13:
					tri_h[2] = data16;
					tri_l[2] = data16_2;
					clr_rec_cnt();
					flash_data[TRI_H_3_ADDR] = (u32) tri_h[2];
					flash_data[TRI_L_3_ADDR] = (u32) tri_l[2];
					qspi_init(XPAR_XQSPIPS_0_DEVICE_ID);
					qspi_write(PARA_ADDR);
					para_update();
					clr_rec_cnt();
					break;
				default:break;
			}
		}
	}
}


//冒泡排序
void bubbleSort(int *arr, int n)
{
	int i=0,j=0;
    for (i = 0; i<n - 1; i++)
    {
        for (j = 0; j < n - i - 1; j++)
        {
            //如果前面的数比后面大，进行交换
            if (arr[j] > arr[j + 1]) {
                int temp = arr[j]; arr[j] = arr[j + 1]; arr[j + 1] = temp;
            }
        }
    }
}

int average(int a[], u16 right, u16 left)
{
	u16 i = 0;
	long sum = 0;
	int aver = 0;
	u16 n = left - right;
	for(i = right; i < left; i++)
	{
		sum += a[i];
	}
	aver = sum / n;
	return aver;
}

void zero_adjust(u8 data[], u8 ch)
{
	int tmp_i[1000];
	int tmp_o[1000];
	u16 i = 0, j = 0;
	for(i = 0; i < 1000; i++)
	{
		tmp_i[i] = (int)((u16)(data[(25+i*2)]<<8)|data[(24+i*2)]);
		tmp_o[i] = tmp_i[i];
	}

//	bubbleSort(tmp_i,1000);
	aver_ch[ch] = average(tmp_i,0,1000);

	for(j = 0; j < 1000; j++)
	{
		tmp_o[j] -= aver_ch[ch];
		data[24 + 2*j] = (u8) tmp_o[j];
		data[25 + 2*j] = (u8) (tmp_o[j]>>8);
	}

}


void DmaReceive(void)
{
	int Status;
	static u16 phase_sin = 0;
	u16 center_value = 0;

	if(first_packet_flag)
	{
		first_packet_flag=0;
		Status = XAxiDma_SimpleTransfer(&AxiDma, (u32)RxBufferPtr[0],(u32)(PAKET_LENGTH), XAXIDMA_DEVICE_TO_DMA);

		if (Status != XST_SUCCESS)
		{
//			xil_printf("axi dma failed! %d \r\n", Status);
			return;
		}
	}

	/*if the last axidma transmission is done, the interrupt triggered, then start TCP transmission*/
	if(packet_trans_done)
	{
		dma_trans_flag = 1;
		packet_trans_done = 0;
		Status = XAxiDma_SimpleTransfer(&AxiDma, (u32)RxBufferPtr[0],(u32)(PAKET_LENGTH), XAXIDMA_DEVICE_TO_DMA);

		if (Status != XST_SUCCESS)
		{
//			xil_printf("axi dma failed! %d \r\n", Status);
			return;
		}
	}

	if((dma_trans_flag)&&(send_flag == 0))
	{
		dma_trans_flag = 0;

		if((switch_rec_flag)&&(!first_packet_flag))
		{
			if(rec_buf1_cnt < sample_quantity)
			{
				rec_flag1 = 0;
				memcpy((receive_buf1+rec_buf1_cnt*SEND_SIZE),RxBufferPtr[0],SEND_SIZE);
				phase_sin = (u16)((syn_data[1]<<8)|syn_data[0]);
				if((receive_buf1[(rec_buf1_cnt*SEND_SIZE)]==0xa5)&&(receive_buf1[(rec_buf1_cnt*SEND_SIZE+1)]==0xa5))
				{
					switch(receive_buf1[(rec_buf1_cnt*SEND_SIZE+16)])
					{
					case 1: phase_sin += 0;
							center_value = flash_data[CENTER_1_ADDR];
	//						zero_adjust(receive_buf1+rec_buf1_cnt*SEND_SIZE,0);
							break;
					case 2: if(phase_sin != 1000)
							{
								phase_sin += 480;
								if(phase_sin >= 720)
								{
									phase_sin -= 720;
								}
							}
							center_value = flash_data[CENTER_2_ADDR];
	//						zero_adjust(receive_buf1+rec_buf1_cnt*SEND_SIZE,1);
							break;
					case 3: if(phase_sin != 1000)
							{
								phase_sin += 240;
								if(phase_sin >= 720)
								{
									phase_sin -= 720;
								}
							}
							center_value = flash_data[CENTER_3_ADDR];
	//						zero_adjust(receive_buf1+rec_buf1_cnt*SEND_SIZE,2);
							break;
					default:break;
					}
					receive_buf1[rec_buf1_cnt*SEND_SIZE+4] = (u8)center_value;
					receive_buf1[rec_buf1_cnt*SEND_SIZE+5] = (u8)(center_value>>8);
					receive_buf1[rec_buf1_cnt*SEND_SIZE+7] = ip4_add;
					receive_buf1[rec_buf1_cnt*SEND_SIZE+8] = (u8)flash_data[3];
					receive_buf1[rec_buf1_cnt*SEND_SIZE+9] = (u8)(flash_data[3]>>8);
					receive_buf1[rec_buf1_cnt*SEND_SIZE+10] = (u8)phase_sin;
					receive_buf1[rec_buf1_cnt*SEND_SIZE+11] = (u8)(phase_sin>>8);
					receive_buf1[rec_buf1_cnt*SEND_SIZE+12] = (u8) rec_buf1_cnt;
					receive_buf1[rec_buf1_cnt*SEND_SIZE+13] = (u8) (rec_buf1_cnt>>8);
					receive_buf1[rec_buf1_cnt*SEND_SIZE+14] = syn_data[2];
					receive_buf1[rec_buf1_cnt*SEND_SIZE+15] = syn_data[3];
					receive_buf1[rec_buf1_cnt*SEND_SIZE+18] = (u8)sample_quantity;
					receive_buf1[rec_buf1_cnt*SEND_SIZE+19] = (u8)(sample_quantity>>8);
					receive_buf1[rec_buf1_cnt*SEND_SIZE+20] = syn_data[4];
					receive_buf1[rec_buf1_cnt*SEND_SIZE+21] = syn_data[5];

					receive_buf1[rec_buf1_cnt*SEND_SIZE+2034] = (u8)flash_data[1];
					receive_buf1[rec_buf1_cnt*SEND_SIZE+2035] = (u8)(flash_data[1]>>8);

					receive_buf1[rec_buf1_cnt*SEND_SIZE+2036] = (u8)(flash_data[2]>>16);
					receive_buf1[rec_buf1_cnt*SEND_SIZE+2037] = (u8)(flash_data[2]>>24);
					receive_buf1[rec_buf1_cnt*SEND_SIZE+2038] = (u8)(flash_data[2]);
					receive_buf1[rec_buf1_cnt*SEND_SIZE+2039] = (u8)(flash_data[2]>>8);
					rec_buf1_cnt++;
				}
			}
			else
			{
				switch_rec_flag = 0;
				rec_buf1_cnt = 0;
				rec_flag1 = 1;
			}
		}
		else if((!switch_rec_flag)&&(!first_packet_flag))
		{
			if(rec_buf2_cnt < sample_quantity)
			{
				rec_flag2 = 0;
				memcpy((receive_buf2+rec_buf2_cnt*SEND_SIZE),RxBufferPtr[0],SEND_SIZE);
				phase_sin = (u16)((syn_data[1]<<8)|syn_data[0]);
				if((receive_buf2[(rec_buf2_cnt*SEND_SIZE)]==0xa5)&&(receive_buf2[(rec_buf2_cnt*SEND_SIZE+1)]==0xa5))
				{
					switch(receive_buf2[rec_buf2_cnt*SEND_SIZE+16])
					{
					case 1: phase_sin += 0;
							center_value = flash_data[CENTER_1_ADDR];
	//						zero_adjust(receive_buf2+rec_buf2_cnt*SEND_SIZE,0);
							break;
					case 2: if(phase_sin != 1000)
							{
								phase_sin += 480;
								if(phase_sin >= 720)
								{
									phase_sin -= 720;
								}
							}
							center_value = flash_data[CENTER_2_ADDR];
	//						zero_adjust(receive_buf2+rec_buf2_cnt*SEND_SIZE,1);
							break;
					case 3: if(phase_sin != 1000)
							{
								phase_sin += 240;
								if(phase_sin >= 720)
								{
									phase_sin -= 720;
								}
							}
							center_value = flash_data[CENTER_3_ADDR];
	//						zero_adjust(receive_buf2+rec_buf2_cnt*SEND_SIZE,2);
							break;
					default:break;
					}
					//phase_tmp = GetPhasePos();
					receive_buf2[rec_buf2_cnt*SEND_SIZE+4] = (u8)center_value;
					receive_buf2[rec_buf2_cnt*SEND_SIZE+5] = (u8)(center_value>>8);
					receive_buf2[rec_buf2_cnt*SEND_SIZE+7] = ip4_add;
					receive_buf2[rec_buf2_cnt*SEND_SIZE+8] = (u8)flash_data[3];
					receive_buf2[rec_buf2_cnt*SEND_SIZE+9] = (u8)(flash_data[3]>>8);
					receive_buf2[rec_buf2_cnt*SEND_SIZE+10] = (u8)phase_sin;
					receive_buf2[rec_buf2_cnt*SEND_SIZE+11] = (u8)(phase_sin>>8);
					receive_buf2[rec_buf2_cnt*SEND_SIZE+12] = (u8) rec_buf2_cnt;
					receive_buf2[rec_buf2_cnt*SEND_SIZE+13] = (u8) (rec_buf2_cnt>>8);
					receive_buf2[rec_buf2_cnt*SEND_SIZE+14] = syn_data[2];
					receive_buf2[rec_buf2_cnt*SEND_SIZE+15] = syn_data[3];
					//receive_buf2[rec_buf2_cnt*SEND_SIZE+17] = get_ch_state();
					receive_buf2[rec_buf2_cnt*SEND_SIZE+18] = (u8)sample_quantity;
					receive_buf2[rec_buf2_cnt*SEND_SIZE+19] = (u8)(sample_quantity>>8);

					receive_buf2[rec_buf2_cnt*SEND_SIZE+20] = syn_data[4];
					receive_buf2[rec_buf2_cnt*SEND_SIZE+21] = syn_data[5];

					receive_buf2[rec_buf2_cnt*SEND_SIZE+2034] = (u8)flash_data[1];
					receive_buf2[rec_buf2_cnt*SEND_SIZE+2035] = (u8)(flash_data[1]>>8);

					receive_buf2[rec_buf2_cnt*SEND_SIZE+2036] = (u8)(flash_data[2]>>16);
					receive_buf2[rec_buf2_cnt*SEND_SIZE+2037] = (u8)(flash_data[2]>>24);
					receive_buf2[rec_buf2_cnt*SEND_SIZE+2038] = (u8)(flash_data[2]);
					receive_buf2[rec_buf2_cnt*SEND_SIZE+2039] = (u8)(flash_data[2]>>8);
					rec_buf2_cnt++;
				}
			}
			else
			{
				switch_rec_flag = 1;
				rec_buf2_cnt = 0;
				rec_flag2 = 1;
			}
		}

		if(rec_flag1)
		{
			if((receive_buf1[16]==1)&&(receive_buf1[(sample_quantity-1)*SEND_SIZE+16]==1))
			{
				ch_now = 1;
			}
			else if((receive_buf1[16]==2)&&(receive_buf1[(sample_quantity-1)*SEND_SIZE+16]==2))
			{
				ch_now = 2;
			}
			else if((receive_buf1[16]==3)&&(receive_buf1[(sample_quantity-1)*SEND_SIZE+16]==3))
			{
				ch_now = 3;
			}
			else
			{
				ch_now = 0;
			}

			switch(ch_now)
			{
				case 1:if(ch1_cnt >= 1)
				       {
						   memcpy(sample_buf,receive_buf1,sample_quantity*SEND_SIZE);
						   gpio_set_chs((1<<1));
						   gpio_set_ch_sel(1<<1);
						   memset(receive_buf1,0,SEND_SIZE*DMA_REC_SIZE);
						   ch_now = 0;
						   rec_flag1 = 0;
						   ch1_cnt = 0;
				       }
				       else
				       {
				    	   memset(receive_buf1,0,SEND_SIZE*DMA_REC_SIZE);
				    	   ch1_cnt++;
				       }
					   break;
				case 2:memcpy((sample_buf+sample_quantity*SEND_SIZE),receive_buf1,sample_quantity*SEND_SIZE);
					   gpio_set_chs((1<<2));
					   gpio_set_ch_sel(1<<2);
					   memset(receive_buf1,0,SEND_SIZE*DMA_REC_SIZE);
					   ch_now = 0;
					   rec_flag1 = 0;
					   break;
				case 3:memcpy((sample_buf+2*sample_quantity*SEND_SIZE),receive_buf1,sample_quantity*SEND_SIZE);
				       send_flag = 1;
				       gpio_set_chs((1<<0));
				       gpio_set_ch_sel(1<<0);
				       memset(receive_buf1,0,SEND_SIZE*DMA_REC_SIZE);
				       ch_now = 0;
				       rec_flag1 = 0;
					   break;
				default:break;
			}
		}
		else if(rec_flag2)
		{
			if((receive_buf2[16]==1)&&(receive_buf2[(sample_quantity-1)*SEND_SIZE+16]==1))
			{
				ch_now = 1;
			}
			else if((receive_buf2[16]==2)&&(receive_buf2[(sample_quantity-1)*SEND_SIZE+16]==2))
			{
				ch_now = 2;
			}
			else if((receive_buf2[16]==3)&&(receive_buf2[(sample_quantity-1)*SEND_SIZE+16]==3))
			{
				ch_now = 3;
			}
			else
			{
				ch_now = 0;
			}
			switch(ch_now)
			{
				case 1:if(ch1_cnt >= 1)
					   {
						   ch1_cnt = 0;
						   memcpy(sample_buf,receive_buf2,sample_quantity*SEND_SIZE);
						   gpio_set_chs((1<<1));
						   gpio_set_ch_sel(1<<1);
						   memset(receive_buf2,0,SEND_SIZE*DMA_REC_SIZE);
						   ch_now = 0;
						   rec_flag2 = 0;
					   }
					   else
					   {
						   memset(receive_buf2,0,SEND_SIZE*DMA_REC_SIZE);
						   ch1_cnt++;
					   }
					   break;
				case 2:memcpy((sample_buf+sample_quantity*SEND_SIZE),receive_buf2,sample_quantity*SEND_SIZE);
					   gpio_set_chs((1<<2));
					   gpio_set_ch_sel(1<<2);
					   memset(receive_buf2,0,SEND_SIZE*DMA_REC_SIZE);
					   ch_now = 0;
					   rec_flag2 = 0;
					   break;
				case 3:memcpy((sample_buf+2*sample_quantity*SEND_SIZE),receive_buf2,sample_quantity*SEND_SIZE);
					   send_flag = 1;
					   gpio_set_chs((1<<0));
					   gpio_set_ch_sel(1<<0);
					   memset(receive_buf2,0,SEND_SIZE*DMA_REC_SIZE);
					   ch_now = 0;
					   rec_flag2 = 0;
					   break;
				default:break;
			}
		}
	}
}

void send_received_data()
{
	#if __arm__
		int copy = 3;
	#else
		int copy = 0;
	#endif
	err_t err;
	struct tcp_pcb *tpcb = connected_pcb;
	if (!connected_pcb)
		return;


	/* if tcp send buffer has enough space to hold the data we want to transmit from PL, then start tcp transmission*/
	if (tcp_sndbuf(tpcb) > SEND_SIZE)
	{
		if(send_flag)
		{
			if(send_cnt < (3*sample_quantity))
			{
				/*transmit received data through TCP*/
				err = tcp_write(tpcb, (sample_buf+send_cnt*SEND_SIZE), SEND_SIZE, copy);
				if (err != ERR_OK)
				{
					tcp_write(tpcb, (sample_buf+send_cnt*SEND_SIZE), SEND_SIZE, copy);
					return;
				}
				err = tcp_output(tpcb);
				send_cnt++;
				if (err != ERR_OK)
				{
					tcp_output(tpcb);
				}
			}
			else
			{
				send_flag=0;
				send_cnt =0;
				running_flag = 0;
				clr_rec_cnt();
			}
		}
		else
		{
			if(sample_quantity_n != sample_quantity)
			{
				sample_quantity = sample_quantity_n;
			}
		}
	}
}

void send_flashdata(void)
{
	#if __arm__
		int copy = 3;
	#else
		int copy = 0;
	#endif
	err_t err;
	struct tcp_pcb *tpcb = connected_pcb;
	u8 data[TEST_FRAME_SIZE]={0};
	data[0] = 0xa6;
	data[1] = 0xa6;
	data[2] = 0x34;
	data[3] = 0x12;
	data[4] = (u8)flash_data[ADJUSTED_ADDR];
	data[5] = (u8)(flash_data[ADJUSTED_ADDR]>>8);
	data[6] = (u8)flash_data[COE_ADDR];
	data[7] = (u8)(flash_data[COE_ADDR]>>8);
	data[8] = (u8)flash_data[OFFSET_ADDR];
	data[9] = (u8)(flash_data[OFFSET_ADDR]>>8);
	data[10] = (u8)flash_data[ID_ADDR];
	data[11] = (u8)(flash_data[ID_ADDR]>>8);
	data[12] = (u8)flash_data[SAM_PER_ADDR];
	data[13] = (u8)(flash_data[SAM_PER_ADDR]>>8);
	data[14] = (u8)flash_data[IP_ADDR];
	data[15] = (u8)(flash_data[IP_ADDR]>>8);
	data[16] = (u8)flash_data[TRI_H_1_ADDR];
	data[17] = (u8)(flash_data[TRI_H_1_ADDR]>>8);
	data[18] = (u8)flash_data[TRI_L_1_ADDR];
	data[19] = (u8)(flash_data[TRI_L_1_ADDR]>>8);
	data[20] = (u8)flash_data[TRI_H_2_ADDR];
	data[21] = (u8)(flash_data[TRI_H_2_ADDR]>>8);
	data[22] = (u8)flash_data[TRI_L_2_ADDR];
	data[23] = (u8)(flash_data[TRI_L_2_ADDR]>>8);
	data[24] = (u8)flash_data[TRI_H_3_ADDR];
	data[25] = (u8)(flash_data[TRI_H_3_ADDR]>>8);
	data[26] = (u8)flash_data[TRI_L_3_ADDR];
	data[27] = (u8)(flash_data[TRI_L_3_ADDR]>>8);
	data[28] = (u8)flash_data[CENTER_1_ADDR];
	data[29] = (u8)(flash_data[CENTER_1_ADDR]>>8);
	data[30] = (u8)flash_data[CENTER_2_ADDR];
	data[31] = (u8)(flash_data[CENTER_2_ADDR]>>8);
	data[32] = (u8)flash_data[CENTER_3_ADDR];
	data[33] = (u8)(flash_data[CENTER_3_ADDR]>>8);
	data[(TEST_FRAME_SIZE-4)] = 0x34;
	data[(TEST_FRAME_SIZE-3)] = 0x12;
	data[(TEST_FRAME_SIZE-2)] = 0x78;
	data[(TEST_FRAME_SIZE-1)] = 0x56;

	if (!connected_pcb)
		return;
	/* if tcp send buffer has enough space to hold the data we want to transmit from PL, then start tcp transmission*/
	if (tcp_sndbuf(tpcb) > TEST_FRAME_SIZE)
	{
		/*transmit received data through TCP*/
		err = tcp_write(tpcb, data, TEST_FRAME_SIZE, copy);
		if (err != ERR_OK)
		{
			tcp_write(tpcb, data, TEST_FRAME_SIZE, copy);
		}
		err = tcp_output(tpcb);
		if (err != ERR_OK)
		{
			tcp_output(tpcb);
		}

	}
}

void tcp_send_data(u8 flag)
{
	#if __arm__
		int copy = 3;
	#else
		int copy = 0;
	#endif
	err_t err;
	struct tcp_pcb *tpcb = connected_pcb;
	u8 data[2048]={0};
	data[0] = 0xa5;
	data[1] = 0xa5;
	data[2] = 0x34;
	data[3] = 0x12;
	data[7] = ip4_add;
	data[8] = (u8)flash_data[3];
	data[9] = (u8)(flash_data[3]>>8);
	data[2044] = 0x34;
	data[2045] = 0x12;
	data[2046] = 0x78;
	data[2047] = 0x56;

	if(flag == 1)
	{
		data[4] = 0xa0;
		data[5] = 0x0a;
		data[6] = 0;
		data[7] = 0;
	}
	else if(flag == 2)
	{
		data[4] = 0xa8;
		data[5] = 0x8a;
		data[6] = 0;
		data[7] = 0;
	}
	if (!connected_pcb)
		return;
	/* if tcp send buffer has enough space to hold the data we want to transmit from PL, then start tcp transmission*/
	if (tcp_sndbuf(tpcb) > SEND_SIZE)
	{
		/*transmit received data through TCP*/
		err = tcp_write(tpcb, data, SEND_SIZE, copy);
		if (err != ERR_OK)
		{
			return;
		}
		err = tcp_output(tpcb);
		if (err != ERR_OK)
		{
			return;
		}

	}
}
//
//
//int tcp_send_init(void)
//{
//	struct tcp_pcb *pcb;
//	struct ip_addr ipaddr;
//	err_t err;
//	u16_t port;
//
//	pcb=tcp_new();
//	if(!pcb)
//	{
////		xil_printf("txperf:Error creating PCB.Out of Memory\r\n");
//		tcp_client_connected = 0;
//		return -1;
//	}
//
//	IP4_ADDR(&ipaddr,192,168,0,185);
//
//	port=7;
//
//	tcp_client_connected = 0;
//	err=tcp_connect(pcb,&ipaddr,port,tcp_connected_callback);
//	if(err!=ERR_OK)
//	{
//		tcp_client_connected = 0;
//		return err;
//	}
//	return 0;
//}
//
//
//
//void lwip_setup(u8 ip)
//{
//
//	struct ip_addr ipaddr, netmask, gw;
//	/* the mac address of the board. this should be unique per board */
//	unsigned char mac_ethernet_address[] = { 0x00, 0x0a, 0x35, 0x00, 0x01, 0x02 };
//
//	netif = &server_netif;
//	IP4_ADDR(&ipaddr,  192, 168,   0,  ip);
//	IP4_ADDR(&netmask, 255, 255, 255,  0);
//	IP4_ADDR(&gw,      192, 168,   0,  1);
//	/*lwip library init*/
//	lwip_init();
//
//	/* Add network interface to the netif_list, and set it as default */
//	if (!xemac_add(netif, &ipaddr, &netmask, &gw, mac_ethernet_address, XPAR_XEMACPS_0_BASEADDR))
//	{
//		xil_printf("Error adding N/W interface\r\n");
//		return ;
//	}
//	netif_set_default(netif);
//	/* specify that the network if is up */
//	netif_set_up(netif);
//	/* initialize tcp pcb */
//	tcp_send_init();
//	sample_quantity_n = sample_quantity;
//
//}
//
//enum tcp_state check_tcp_state()
//{
//	struct tcp_pcb *tpcb = connected_pcb;
//	return tpcb->state;
//}
//
//void tcp_client_close()
//{
//	struct tcp_pcb *tpcb = connected_pcb;
//	tcp_close(tpcb);
//}
//
//void tcp_client_reconnect()  //reconnect automatically
//{
//	struct tcp_pcb *tpcb = connected_pcb;
//	 if((tpcb->state != ESTABLISHED))
//	 {
//		 if(tpcb->state != CLOSED)
//		 {
//			 tcp_close(tpcb);
//		 }
//		 tcp_send_init();
//	 }
//}

void m_tcp_fasttmr(void)
{
	tcp_fasttmr();
}

void m_tcp_slowtmr(void)
{
	tcp_slowtmr();
}

err_t recv_callback(void *arg, struct tcp_pcb *tpcb,
                               struct pbuf *p, err_t err)
{
	/* do not read the packet if we are not in ESTABLISHED state */
	if (!p) {
		tcp_close(tpcb);
		tcp_recv(tpcb, NULL);
		return ERR_OK;
	}
	connected_pcb  = tpcb;

	memset(lwip_rec_buf,0,8);
	/* indicate that the packet has been received */
	tcp_recved(tpcb, p->len);

	/* echo back the payload */
	/* in this case, we assume that the payload is < TCP_SND_BUF */
	if (tcp_sndbuf(tpcb) > p->len) {
		memcpy(lwip_rec_buf,(u8*)(p->payload),p->len);
		tcp_recv_flag = 1;
//		err = tcp_write(tpcb, p->payload, p->len, 1);
	} else
		xil_printf("no space in tcp_sndbuf\n\r");

	/* free the received pbuf */
	pbuf_free(p);

	return ERR_OK;
}

err_t accept_callback(void *arg, struct tcp_pcb *newpcb, err_t err)
{
	static int connection = 1;

	/* set the receive callback for this connection */
	tcp_recv(newpcb, recv_callback);

	/* just use an integer number indicating the connection id as the
	   callback argument */
	tcp_arg(newpcb, (void*)connection);

	/* increment for subsequent accepted connections */
	connection++;

	return ERR_OK;
}

int start_application()
{
	struct tcp_pcb *pcb;
	err_t err;
	unsigned port = 7;

	/* create new TCP PCB structure */
	pcb = tcp_new();
	if (!pcb) {
		xil_printf("Error creating PCB. Out of Memory\n\r");
		return -1;
	}

	/* bind to specified @port */
	err = tcp_bind(pcb, IP_ADDR_ANY, port);
	if (err != ERR_OK) {
		xil_printf("Unable to bind to port %d: err = %d\n\r", port, err);
		return -2;
	}

	/* we do not need any arguments to callback functions */
	tcp_arg(pcb, NULL);

	/* listen for connections */
	pcb = tcp_listen(pcb);
	if (!pcb) {
		xil_printf("Out of memory while tcp_listen\n\r");
		return -3;
	}

	/* specify callback to use for incoming connections */
	tcp_accept(pcb, accept_callback);

	xil_printf("TCP echo server started @ port %d\n\r", port);

	return 0;
}


void lwip_server_setup(u8 ip)
{
	struct ip_addr ipaddr, netmask, gw;

	/* the mac address of the board. this should be unique per board */
	unsigned char mac_ethernet_address[] =
	{ 0x00, 0x0a, 0x35, 0x00, 0x01, 0x02 };

	echo_netif = &server_netif;

	/* initliaze IP addresses to be used */
	IP4_ADDR(&ipaddr,  192, 168,   2, ip);
	IP4_ADDR(&netmask, 255, 255, 255,  0);
	IP4_ADDR(&gw,      192, 168,   2,  1);

	lwip_init();

  	/* Add network interface to the netif_list, and set it as default */
	if (!xemac_add(echo_netif, &ipaddr, &netmask,
						&gw, mac_ethernet_address,
						PLATFORM_EMAC_BASEADDR)) {
		xil_printf("Error adding N/W interface\n\r");
	}
	netif_set_default(echo_netif);

	/* now enable interrupts */
//	platform_enable_interrupts();

	/* specify that the network if is up */
	netif_set_up(echo_netif);


	/* start the application (web server, rxtest, txtest, etc..) */
	start_application();
}



