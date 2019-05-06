vlib work
vlib msim

vlib msim/xbip_utils_v3_0_5
vlib msim/axi_utils_v2_0_1
vlib msim/fir_compiler_v7_2_5
vlib msim/xil_defaultlib

vmap xbip_utils_v3_0_5 msim/xbip_utils_v3_0_5
vmap axi_utils_v2_0_1 msim/axi_utils_v2_0_1
vmap fir_compiler_v7_2_5 msim/fir_compiler_v7_2_5
vmap xil_defaultlib msim/xil_defaultlib

vcom -work xbip_utils_v3_0_5 -64 -93 \
"../../../ipstatic/xbip_utils_v3_0_5/hdl/xbip_utils_v3_0_vh_rfs.vhd" \

vcom -work axi_utils_v2_0_1 -64 -93 \
"../../../ipstatic/axi_utils_v2_0_1/hdl/axi_utils_v2_0_vh_rfs.vhd" \

vcom -work fir_compiler_v7_2_5 -64 -93 \
"../../../ipstatic/fir_compiler_v7_2_5/hdl/fir_compiler_v7_2_vh_rfs.vhd" \
"../../../ipstatic/fir_compiler_v7_2_5/hdl/fir_compiler_v7_2.vhd" \

vcom -work xil_defaultlib -64 -93 \
"../../../../../../Miz_ip_lib/DataGenV5_3ch_mod/sources_1/src/fir_compiler_0/sim/fir_compiler_0.vhd" \

