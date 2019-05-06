/*
 * shared_mem.h
 *
 *  Created on: 2017��2��7��
 * www.osrc.cn
 * www.milinker.com
 * copyright by nan jin mi lian dian zi www.osrc.cn
*/

#ifndef SHARED_MEM_H_
#define SHARED_MEM_H_

#include "xil_types.h"
#include "xil_cache.h"
#include "string.h"

typedef struct
{
	u32 data_length;
	u8* dataload;
}shared_region;

extern shared_region *region_cpu0;
extern shared_region *region;
extern u8 *data_to_cpu0;
extern u8 *data_from_cpu0;
void get_data_from_region(u8 *buffer,  shared_region *p);
void put_data_to_region(u8 *src_buffer, u8 *dst_buffer, u32 length, shared_region *p);
void shared_mem_init(void);
#endif /* SHARED_MEM_H_ */
