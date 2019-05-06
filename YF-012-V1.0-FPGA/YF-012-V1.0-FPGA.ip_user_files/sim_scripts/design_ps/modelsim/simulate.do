onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -t 1ps -pli "D:/Xlinx/Vivado/2015.4/lib/win64.o/libxil_vsim.dll" -L unisims_ver -L unimacro_ver -L secureip -L xil_defaultlib -L lib_pkg_v1_0_2 -L fifo_generator_v13_0_1 -L lib_fifo_v1_0_4 -L lib_srl_fifo_v1_0_2 -L lib_cdc_v1_0_2 -L axi_datamover_v5_1_9 -L axi_sg_v4_1_2 -L axi_dma_v7_1_8 -L axis_infrastructure_v1_1_0 -L axis_data_fifo_v1_1_8 -L proc_sys_reset_v5_0_8 -L generic_baseblocks_v2_1_0 -L axi_infrastructure_v1_1_0 -L axi_register_slice_v2_1_7 -L axi_data_fifo_v2_1_6 -L axi_crossbar_v2_1_8 -L axi_lite_ipif_v3_0_3 -L interrupt_control_v3_1_3 -L axi_gpio_v2_0_9 -L xbip_utils_v3_0_5 -L axi_utils_v2_0_1 -L fir_compiler_v7_2_5 -L xbip_pipe_v3_0_1 -L xbip_bram18k_v3_0_1 -L mult_gen_v12_0_10 -L xbip_dsp48_wrapper_v3_0_4 -L xbip_dsp48_addsub_v3_0_1 -L xbip_dsp48_multadd_v3_0_1 -L dds_compiler_v6_0_11 -L axi_uartlite_v2_0_10 -L axi_protocol_converter_v2_1_7 -L axi_clock_converter_v2_1_6 -L blk_mem_gen_v8_3_1 -L axi_dwidth_converter_v2_1_7 -lib xil_defaultlib xil_defaultlib.design_ps xil_defaultlib.glbl

do {wave.do}

view wave
view structure
view signals

do {design_ps.udo}

run -all

quit -force
