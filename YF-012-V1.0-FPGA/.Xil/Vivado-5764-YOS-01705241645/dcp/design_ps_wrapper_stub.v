// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module design_ps_wrapper(DDR_addr, DDR_ba, DDR_cas_n, DDR_ck_n, DDR_ck_p, DDR_cke, DDR_cs_n, DDR_dm, DDR_dq, DDR_dqs_n, DDR_dqs_p, DDR_odt, DDR_ras_n, DDR_reset_n, DDR_we_n, FIXED_IO_ddr_vrn, FIXED_IO_ddr_vrp, FIXED_IO_mio, FIXED_IO_ps_clk, FIXED_IO_ps_porb, FIXED_IO_ps_srstb, Vaux3_v_n, Vaux3_v_p, ch_en1_tri_o, ch_en2_tri_o, ch_en3_tri_o, clk_n, clk_p, hf_ch1, hf_ch2, hf_ch3, led);
  inout [14:0]DDR_addr;
  inout [2:0]DDR_ba;
  inout DDR_cas_n;
  inout DDR_ck_n;
  inout DDR_ck_p;
  inout DDR_cke;
  inout DDR_cs_n;
  inout [3:0]DDR_dm;
  inout [31:0]DDR_dq;
  inout [3:0]DDR_dqs_n;
  inout [3:0]DDR_dqs_p;
  inout DDR_odt;
  inout DDR_ras_n;
  inout DDR_reset_n;
  inout DDR_we_n;
  inout FIXED_IO_ddr_vrn;
  inout FIXED_IO_ddr_vrp;
  inout [53:0]FIXED_IO_mio;
  inout FIXED_IO_ps_clk;
  inout FIXED_IO_ps_porb;
  inout FIXED_IO_ps_srstb;
  input Vaux3_v_n;
  input Vaux3_v_p;
  output [0:0]ch_en1_tri_o;
  output [0:0]ch_en2_tri_o;
  output [0:0]ch_en3_tri_o;
  input clk_n;
  input clk_p;
  input [15:0]hf_ch1;
  input [15:0]hf_ch2;
  input [15:0]hf_ch3;
  output [0:0]led;
endmodule
