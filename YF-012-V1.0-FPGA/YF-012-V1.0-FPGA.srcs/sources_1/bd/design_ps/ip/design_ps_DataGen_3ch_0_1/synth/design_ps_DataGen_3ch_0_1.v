// (c) Copyright 1995-2018 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: xilinx.com:user:DataGen_3ch:1.0
// IP Revision: 4

(* X_CORE_INFO = "DataGen_3ch,Vivado 2015.4" *)
(* CHECK_LICENSE_TYPE = "design_ps_DataGen_3ch_0_1,DataGen_3ch,{}" *)
(* CORE_GENERATION_INFO = "design_ps_DataGen_3ch_0_1,DataGen_3ch,{x_ipProduct=Vivado 2015.4,x_ipVendor=xilinx.com,x_ipLibrary=user,x_ipName=DataGen_3ch,x_ipVersion=1.0,x_ipCoreRevision=4,x_ipLanguage=VHDL,x_ipSimLanguage=MIXED}" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module design_ps_DataGen_3ch_0_1 (
  clk,
  rst,
  hf_ch1,
  hf_ch2,
  hf_ch3,
  trig_level_h_ch1,
  trig_level_l_ch1,
  trig_level_h_ch2,
  trig_level_l_ch2,
  trig_level_h_ch3,
  trig_level_l_ch3,
  pretrig,
  trig_length,
  dds_config_data,
  pulse_period,
  pulse_offset,
  pulse_width,
  adjusted_value,
  src_sel,
  ch_sel,
  DataGen_ready,
  hf_ch_send_flag,
  S_AXIS_start,
  S_AXIS_aclk,
  S_AXIS_aresetn,
  S_AXIS_tready,
  S_AXIS_tdata,
  S_AXIS_tkeep,
  S_AXIS_tvalid,
  S_AXIS_tlast
);

(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clk CLK" *)
input wire clk;
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 rst RST" *)
input wire rst;
input wire [15 : 0] hf_ch1;
input wire [15 : 0] hf_ch2;
input wire [15 : 0] hf_ch3;
input wire [15 : 0] trig_level_h_ch1;
input wire [15 : 0] trig_level_l_ch1;
input wire [15 : 0] trig_level_h_ch2;
input wire [15 : 0] trig_level_l_ch2;
input wire [15 : 0] trig_level_h_ch3;
input wire [15 : 0] trig_level_l_ch3;
input wire [15 : 0] pretrig;
input wire [15 : 0] trig_length;
input wire [31 : 0] dds_config_data;
input wire [15 : 0] pulse_period;
input wire [15 : 0] pulse_offset;
input wire [15 : 0] pulse_width;
input wire [15 : 0] adjusted_value;
input wire src_sel;
input wire [3 : 0] ch_sel;
input wire DataGen_ready;
output wire hf_ch_send_flag;
input wire S_AXIS_start;
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 S_AXIS_aclk CLK" *)
output wire S_AXIS_aclk;
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 S_AXIS_aresetn RST" *)
output wire S_AXIS_aresetn;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TREADY" *)
input wire S_AXIS_tready;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TDATA" *)
output wire [15 : 0] S_AXIS_tdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TKEEP" *)
output wire [1 : 0] S_AXIS_tkeep;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TVALID" *)
output wire S_AXIS_tvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TLAST" *)
output wire S_AXIS_tlast;

  DataGen_3ch inst (
    .clk(clk),
    .rst(rst),
    .hf_ch1(hf_ch1),
    .hf_ch2(hf_ch2),
    .hf_ch3(hf_ch3),
    .trig_level_h_ch1(trig_level_h_ch1),
    .trig_level_l_ch1(trig_level_l_ch1),
    .trig_level_h_ch2(trig_level_h_ch2),
    .trig_level_l_ch2(trig_level_l_ch2),
    .trig_level_h_ch3(trig_level_h_ch3),
    .trig_level_l_ch3(trig_level_l_ch3),
    .pretrig(pretrig),
    .trig_length(trig_length),
    .dds_config_data(dds_config_data),
    .pulse_period(pulse_period),
    .pulse_offset(pulse_offset),
    .pulse_width(pulse_width),
    .adjusted_value(adjusted_value),
    .src_sel(src_sel),
    .ch_sel(ch_sel),
    .DataGen_ready(DataGen_ready),
    .hf_ch_send_flag(hf_ch_send_flag),
    .S_AXIS_start(S_AXIS_start),
    .S_AXIS_aclk(S_AXIS_aclk),
    .S_AXIS_aresetn(S_AXIS_aresetn),
    .S_AXIS_tready(S_AXIS_tready),
    .S_AXIS_tdata(S_AXIS_tdata),
    .S_AXIS_tkeep(S_AXIS_tkeep),
    .S_AXIS_tvalid(S_AXIS_tvalid),
    .S_AXIS_tlast(S_AXIS_tlast)
  );
endmodule
