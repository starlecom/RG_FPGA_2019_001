/*
 *
 * www.osrc.cn
 * www.milinker.com
 * copyright by nan jin mi lian dian zi www.osrc.cn
*/
#ifndef M_LWIP_H
#define M_LWIP_H

#include <stdlib.h>
#include "xparameters.h"
#include "xaxidma.h"
#include "lwip/tcp.h"
#include "xil_cache.h"
#include "xil_printf.h"
#include "lwip/err.h"
#include "lwipopts.h"
#include "netif/xadapter.h"
#include "lwipopts.h"
#include "gpio_dev.h"
#include "timer_intr.h"
#include "software_intr.h"
#include "xqspips_flash.h"
#include "platform_config.h"
#include <sleep.h>


#define TEST_FRAME_SIZE (2048)
#define SEND_SIZE (2*1024)
#define PAKET_LENGTH (2*1024)
#define DMA_REC_SIZE  2000

extern int tcp_recv_cnt;

extern struct netif *echo_netif;
extern XAxiDma AxiDma;
extern volatile unsigned tcp_client_connected;
extern int packet_trans_done;
extern u8 first_packet_flag;
extern u8 syn_mode_flag;
extern u8 send_flag;
extern u16 sample_time;
extern u8  ip4_add;
extern u8 running_flag;
extern u16 tmr_disconnect_cnt;

void clr_rec_cnt(void);
void DmaReceive(void);
void tcp_slowtmr(void);
void tcp_fasttmr(void);
void lwip_init(void);
void lwip_setup(u8 ip);
void lwip_server_setup(u8 ip);
void m_tcp_fasttmr(void);
void m_tcp_slowtmr(void);
void send_received_data();

void TcpRecv(void);

#endif