
/*
 *
 * www.osrc.cn
 * www.milinker.com
 * copyright by nan jin mi lian dian zi www.osrc.cn
*/
#include "lwip_mod.h"


#define REC_BUF_SIZE 64

struct netif *netif, server_netif;
static struct tcp_pcb *connected_pcb=NULL;
volatile unsigned tcp_client_connected=0;
static int tcp_trans_done=0;
int tcp_recv_cnt=0;
int packet_trans_done=0;
u8 dma_trans_flag=0;
u8 first_packet_flag=1;
u8 syn_mode_flag=0;
extern u16 *RxBufferPtr[1];  /* ping pong buffers*/
static u8 lwip_rec_buf[REC_BUF_SIZE];
static u8 tcp_recv_flag=0;
static u8 sample_buf[3*SEND_SIZE*DMA_REC_SIZE];
static u8 receive_buf1[SEND_SIZE*DMA_REC_SIZE];
static u8 receive_buf2[SEND_SIZE*DMA_REC_SIZE];
static u8 trans_buffer[SEND_SIZE];
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
u16 tmr_sample_flag = 0;
u16 sample_time = 120;
u8  ip4_add = 10;
u8 g_sample_err = 0;

u8 ch1_cnt = 0;      //抛弃第一次采集的数据

int aver_ch[3] = {0};

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
	u8 keyword = 0;
	u16 tri_h[3] = {0};
	u16 tri_l[3] = {0};
	u8 i =0;
	if(tcp_recv_flag > 0)
	{
		tcp_recv_flag = 0;
		if((lwip_rec_buf[0]==0xa8)&&(lwip_rec_buf[1]==(u8)flash_data[ID_ADDR])&&(lwip_rec_buf[7]==0x78))
		{
			//解析命令
			data32  = (lwip_rec_buf[6]<<24)|(lwip_rec_buf[5]<<16)|(lwip_rec_buf[4]<<8)|lwip_rec_buf[3];
			data16  = (lwip_rec_buf[4]<<8)|lwip_rec_buf[3];
			data16_2= (lwip_rec_buf[6]<<8)|lwip_rec_buf[5];
			keyword = lwip_rec_buf[2];
			memset(lwip_rec_buf,0,8);
			clr_rec_cnt();
			switch(keyword)
			{
				case 0x01:
					for(i = 0; i < 3; i++)
					{
						tri_h[i] = data16 + aver_ch[i];
						tri_l[i] = data16_2 + aver_ch[i];
					}
					gpio_set_trig_h_ch1(tri_h[0]);
					gpio_set_trig_l_ch1(tri_l[0]);
					gpio_set_trig_h_ch2(tri_h[1]);
					gpio_set_trig_l_ch2(tri_l[1]);
					gpio_set_trig_h_ch3(tri_h[2]);
					gpio_set_trig_l_ch3(tri_l[2]);
					clr_rec_cnt();
					break;
				case 0x02:         //
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
				default:break;
			}
		}
	}
}

static err_t tcp_sent_callback(void *arg, struct tcp_pcb *tpcb, u16_t len)
{
	tcp_trans_done ++;
	return ERR_OK;
}

static err_t tcp_recv_callback(void *arg, struct tcp_pcb *tpcb, struct pbuf *p, err_t err)
{
	memset(lwip_rec_buf,0,8);
	/* do not read the packet if we are not in ESTABLISHED state */
	if (!p)
	{
		tcp_close(tpcb);
		tcp_recv(tpcb, NULL);
		return ERR_OK;
	}

	/* indicate that the packet has been received */
	tcp_recved(tpcb, p->len);

	if(p != NULL)
	{
		memcpy(lwip_rec_buf,(u8*)(p->payload),p->len);
		tcp_recv_flag = 1;
		//xil_printf("\nrecv_len=%d\n\r",p->len);
	}

	/* free the received pbuf */
	pbuf_free(p);
	return ERR_OK;
}

static err_t tcp_connected_callback(void *arg, struct tcp_pcb *tpcb, err_t err)
{
//	xil_printf("txperf: Connected to iperf server\r\n");
	/* store state */
	connected_pcb = tpcb;
	/* set callback values & functions */
	tcp_arg(tpcb, NULL);
	tcp_sent(tpcb, tcp_sent_callback);
	tcp_recv(tpcb, tcp_recv_callback);
	tcp_client_connected = 1;
	/* initiate data transfer */
	return ERR_OK;
}

void m_tcp_tmr(void)
{
	tcp_tmr();
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

	if(dma_trans_flag)
	{
		dma_trans_flag = 0;
//		Status = XAxiDma_SimpleTransfer(&AxiDma, (u32)RxBufferPtr[0],(u32)(PAKET_LENGTH), XAXIDMA_DEVICE_TO_DMA);
//
//		if (Status != XST_SUCCESS)
//		{
//			xil_printf("axi dma failed! %d \r\n", Status);
//			return;
//		}

		if((switch_rec_flag)&&(!first_packet_flag))
		{
			if(rec_buf1_cnt < sample_quantity)
			{
				rec_flag1 = 0;
				memcpy((receive_buf1+rec_buf1_cnt*SEND_SIZE),RxBufferPtr[0],SEND_SIZE);
				phase_sin = (u16)((syn_data[1]<<8)|syn_data[0]);
//				if((receive_buf1[(rec_buf1_cnt*SEND_SIZE)]==0xa5)&&(receive_buf1[(rec_buf1_cnt*SEND_SIZE+1)]==0xa5))
				switch(receive_buf1[(rec_buf1_cnt*SEND_SIZE+16)])
				{
				case 1: phase_sin += 0;
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
//						zero_adjust(receive_buf1+rec_buf1_cnt*SEND_SIZE,2);
						break;
				default:break;
				}
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
				switch(receive_buf2[rec_buf2_cnt*SEND_SIZE+16])
				{
				case 1: phase_sin += 0;
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
//						zero_adjust(receive_buf2+rec_buf2_cnt*SEND_SIZE,2);
						break;
				default:break;
				}
				//phase_tmp = GetPhasePos();
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
					   memset(receive_buf2,0,SEND_SIZE*DMA_REC_SIZE);
					   ch_now = 0;
					   rec_flag2 = 0;
					   break;
				default:break;
			}
		}

		if(send_flag)
		{
			gpio_set_chs((1<<0));
			gpio_set_ch_sel(1<<0);
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

	if(g_sample_err)
	{
		g_sample_err = 0;
		tcp_close(tpcb);
		tcp_recv(tpcb, NULL);
		tcp_client_connected = 0;
		clr_rec_cnt();
	}

	/* if tcp send buffer has enough space to hold the data we want to transmit from PL, then start tcp transmission*/
	if (tcp_sndbuf(tpcb) > SEND_SIZE)
	{
		if(send_flag)
		{
			tmr_sample_flag = 0;
			if(send_cnt < (3*sample_quantity))
			{
				/*transmit received data through TCP*/
				err = tcp_write(tpcb, (sample_buf+send_cnt*SEND_SIZE), SEND_SIZE, copy);
				if (err != ERR_OK)
				{
//					xil_printf("txperf: Error on tcp_write: %d\r\n", err);
					connected_pcb = NULL;
					tcp_close(tpcb);
					tcp_recv(tpcb, NULL);
					tcp_client_connected = 0;
					clr_rec_cnt();
					return;
				}
				err = tcp_output(tpcb);
				send_cnt++;
				if (err != ERR_OK)
				{
//					xil_printf("txperf: Error on tcp_output: %d\r\n",err);
					return;
				}
			}
			else
			{
				send_flag=0;
				send_cnt =0;
				tcp_close(tpcb);
				tcp_recv(tpcb, NULL);
				tcp_client_connected = 0;
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
			xil_printf("txperf: Error on tcp_write: %d\r\n", err);
			connected_pcb = NULL;
//			tcp_client_connected= 0;
			tcp_close(tpcb);
			tcp_recv(tpcb, NULL);
			tcp_client_connected = 0;
			clr_rec_cnt();
			return;
		}
		err = tcp_output(tpcb);
		if (err != ERR_OK)
		{
			xil_printf("txperf: Error on tcp_output: %d\r\n",err);
			return;
		}

	}
}

int tcp_send_init(void)
{
	struct tcp_pcb *pcb;
	struct ip_addr ipaddr;
	err_t err;
	u16_t port;

	pcb=tcp_new();
	if(!pcb)
	{
		xil_printf("txperf:Error creating PCB.Out of Memory\r\n");
		return -1;
	}

	IP4_ADDR(&ipaddr,192,168,0,101);

	port=7;

	tcp_client_connected=0;

//	packet_trans_done=0;

	err=tcp_connect(pcb,&ipaddr,port,tcp_connected_callback);
	tmr_sample_flag = 1;
	if(err!=ERR_OK)
	{
		xil_printf("txperf:tcp_connect return error!%d\r\n",err);
		return err;
	}
	return 0;
}



void lwip_setup(u8 ip)
{

	struct ip_addr ipaddr, netmask, gw;
	/* the mac address of the board. this should be unique per board */
	unsigned char mac_ethernet_address[] = { 0x00, 0x0a, 0x35, 0x00, 0x01, 0x02 };
	
	netif = &server_netif;
	IP4_ADDR(&ipaddr,  192, 168,   0,  ip);
	IP4_ADDR(&netmask, 255, 255, 255,  0);
	IP4_ADDR(&gw,      192, 168,   0,  1);
	/*lwip library init*/
	lwip_init();

	/* Add network interface to the netif_list, and set it as default */
	if (!xemac_add(netif, &ipaddr, &netmask, &gw, mac_ethernet_address, XPAR_XEMACPS_0_BASEADDR))
	{
		xil_printf("Error adding N/W interface\r\n");
		return ;
	}
	netif_set_default(netif);
	/* specify that the network if is up */
	netif_set_up(netif);
	/* initialize tcp pcb */
	tcp_send_init();
	sample_quantity_n = sample_quantity;

}




