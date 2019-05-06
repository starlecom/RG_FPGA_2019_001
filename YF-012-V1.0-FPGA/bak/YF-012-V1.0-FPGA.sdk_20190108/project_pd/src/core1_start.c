
/*
 *
 * www.osrc.cn
 * www.milinker.com
 * copyright by nan jin mi lian dian zi www.osrc.cn
 *
 *
*/



#include "core1_start.h"



#define QSPI_DEVICE_ID		XPAR_XQSPIPS_0_DEVICE_ID
#define TIMER_LOAD_VALUE    XPAR_CPU_CORTEXA9_0_CPU_CLK_FREQ_HZ / 8 //0.25S

#define CPU1_CATCH			0x00000024   //entry of code start address of core1's application, defined in asm_vectors.s in fsbl bsp's standalone
#define APP_CPU1_ADDR	    0x04000000   //code start address of core1's application
#define A9_CPU_RST_CTRL		(XSLCR_BASEADDR + 0x244)
#define A9_RST1_MASK 		0x00000002
#define A9_CLKSTOP1_MASK	0x00000020

#define XSLCR_LOCK_ADDR		(XSLCR_BASEADDR + 0x4)
#define XSLCR_LOCK_CODE		0x0000767B


void Start_cpu1(void)
{
   	u32 RegVal;

    //Disable cache on OCM
    Xil_SetTlbAttributes(0xFFFF0000,0x14de2);           // S=b1 TEX=b100 AP=b11, Domain=b1111, C=b0, B=b0

    //Disable cache on fsbl vector table location
    Xil_SetTlbAttributes(0x00000000,0x14de2);           // S=b1 TEX=b100 AP=b11, Domain=b1111, C=b0, B=b0

	/*
	 *  Reset and start CPU1
	 *  - Application for cpu1 exists at 0x00000000 per cpu1 linkerscript
	 *
	 */

	/*
	 * Setup cpu1 catch address with starting address of app_cpu1. The FSBL initialized the vector table at 0x00000000
	 * using a boot.S that checks for cpu number and jumps to the address stored at the
	 * end of the vector table in cpu0_catch and cpu1_catch entries.
	 * Note: Cache has been disabled at the beginning of main(). Otherwise
	 * a cache flush would have to be issued after this write
	 */
	Xil_Out32(CPU1_CATCH, APP_CPU1_ADDR);

	/* Unlock the slcr register access lock */
	Xil_Out32(XSLCR_UNLOCK_ADDR, XSLCR_UNLOCK_CODE);

	//    the user must stop the associated clock, de-assert the reset, and then restart the clock. During a
	//    system or POR reset, hardware automatically takes care of this. Therefore, a CPU cannot run the code
	//    that applies the software reset to itself. This reset needs to be applied by the other CPU or through
	//    JTAG or PL. Assuming the user wants to reset CPU1, the user must to set the following fields in the
	//    slcr.A9_CPU_RST_CTRL (address 0xF8000244) register in the order listed:
	//    1. A9_RST1 = 1 to assert reset to CPU1
	//    2. A9_CLKSTOP1 = 1 to stop clock to CPU1
	//    3. A9_RST1 = 0 to release reset to CPU1
	//    4. A9_CLKSTOP1 = 0 to restart clock to CPU1

	/* Assert and deassert cpu1 reset and clkstop using above sequence*/
	RegVal = 	Xil_In32(A9_CPU_RST_CTRL);
	RegVal |= A9_RST1_MASK;
	Xil_Out32(A9_CPU_RST_CTRL, RegVal);
	RegVal |= A9_CLKSTOP1_MASK;
	Xil_Out32(A9_CPU_RST_CTRL, RegVal);
	RegVal &= ~A9_RST1_MASK;
	Xil_Out32(A9_CPU_RST_CTRL, RegVal);
	RegVal &= ~A9_CLKSTOP1_MASK;
	Xil_Out32(A9_CPU_RST_CTRL, RegVal);

	/* lock the slcr register access */
	Xil_Out32(XSLCR_LOCK_ADDR, XSLCR_LOCK_CODE);
}



