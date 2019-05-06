/*
 *
 * www.osrc.cn
 * www.milinker.com
 * copyright by nan jin mi lian dian zi www.osrc.cn
*/
#if 1
#ifndef M_GPIO_H
#define M_GPIO_H

#include "xparameters.h"
#include "xgpio.h"

/************************** Constant Definitions *****************************/
/*
 * Device hardware build related constants.
 */

#define GPIO_DIR_OUTPUT			0
#define GPIO_DIR_INPUT			1

#define GPIO_ID_SEND_FLAG		XPAR_AXI_GPIO_0_DEVICE_ID
#define GPIO_ID_START_FLAG		XPAR_AXI_GPIO_1_DEVICE_ID
#define GPIO_ID_TRIG_H_CH1		XPAR_AXI_GPIO_2_DEVICE_ID
#define GPIO_ID_TRIG_L_CH1		XPAR_AXI_GPIO_17_DEVICE_ID
#define GPIO_ID_TRIG_H_CH2		XPAR_AXI_GPIO_21_DEVICE_ID
#define GPIO_ID_TRIG_L_CH2		XPAR_AXI_GPIO_19_DEVICE_ID
#define GPIO_ID_TRIG_H_CH3		XPAR_AXI_GPIO_18_DEVICE_ID
#define GPIO_ID_TRIG_L_CH3		XPAR_AXI_GPIO_20_DEVICE_ID
#define GPIO_ID_PRETRIG			XPAR_AXI_GPIO_3_DEVICE_ID
#define GPIO_ID_TRIG_LENGTH		XPAR_AXI_GPIO_4_DEVICE_ID
#define GPIO_ID_DDS_CONFIG		XPAR_AXI_GPIO_5_DEVICE_ID
#define GPIO_ID_PULSE_PERIOD	XPAR_AXI_GPIO_6_DEVICE_ID
#define GPIO_ID_PULSE_OFFSET	XPAR_AXI_GPIO_7_DEVICE_ID
#define GPIO_ID_PULSE_WIDTH		XPAR_AXI_GPIO_8_DEVICE_ID
#define GPIO_ID_SRC_SEL			XPAR_AXI_GPIO_9_DEVICE_ID
#define GPIO_ID_DATAGEN_READY	XPAR_AXI_GPIO_10_DEVICE_ID
#define GPIO_ID_LED				XPAR_AXI_GPIO_11_DEVICE_ID
#define GPIO_ID_CH_SEL			XPAR_AXI_GPIO_12_DEVICE_ID
#define GPIO_ID_CH_EN1			XPAR_AXI_GPIO_13_DEVICE_ID
#define GPIO_ID_CH_EN2			XPAR_AXI_GPIO_14_DEVICE_ID
#define GPIO_ID_CH_EN3			XPAR_AXI_GPIO_15_DEVICE_ID
#define GPIO_ID_ADJUSTED_VALUE	XPAR_AXI_GPIO_16_DEVICE_ID

int  m_gpio_init(void);

void gpio_set_start_flag	(u16 dat);
void gpio_set_trig_h_ch1	(u16 dat);
void gpio_set_trig_l_ch1	(u16 dat);
void gpio_set_trig_h_ch2	(u16 dat);
void gpio_set_trig_l_ch2	(u16 dat);
void gpio_set_trig_h_ch3	(u16 dat);
void gpio_set_trig_l_ch3	(u16 dat);
void gpio_set_pretrig		(u16 dat);
void gpio_set_trig_length	(u16 dat);
void gpio_set_dds_config	(u32 dat);
void gpio_set_pulse_period	(u16 dat);
void gpio_set_pulse_offset	(u16 dat);
void gpio_set_pulse_width	(u16 dat);
void gpio_set_src_sel		(u16 dat);
void gpio_set_datagen_ready	(u16 dat);
void gpio_set_led			(u16 dat);
void gpio_set_ch_sel		(u16 dat);
void gpio_set_ch_en1		(u16 dat);
void gpio_set_ch_en2		(u16 dat);
void gpio_set_ch_en3		(u16 dat);
void gpio_set_chs           (u16 dat);
void gpio_set_adjusted_value(u16 dat);

u8 m_gpio_get(void);
u8 get_ch_state(void);

#endif

#endif
