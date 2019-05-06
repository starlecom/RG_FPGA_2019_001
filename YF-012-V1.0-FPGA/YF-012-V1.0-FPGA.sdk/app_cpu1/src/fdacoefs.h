/*
 * Filter Coefficients (C Source) generated by the Filter Design and Analysis Tool
 * Generated by MATLAB(R) 9.1 and the Signal Processing Toolbox 7.3.
 * Generated on: 06-Dec-2017 14:00:07
 */

#include "xil_types.h"
/*
 * Discrete-Time FIR Filter (real)
 * -------------------------------
 * Filter Structure  : Direct-Form FIR
 * Filter Length     : 26
 * Stable            : Yes
 * Linear Phase      : Yes (Type 2)
 */
#define ORDER  257
#define LF_DATA_SIZE  (2000*2+ORDER)

int filter(u32 *indata,u32 *outdata); /*FIR��ͨ�˲��ӳ���*/