-- (c) Copyright 1995-2018 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-- 
-- DO NOT MODIFY THIS FILE.

-- IP VLNV: xilinx.com:user:DataGen_3ch:1.0
-- IP Revision: 4

-- The following code must appear in the VHDL architecture header.

------------- Begin Cut here for COMPONENT Declaration ------ COMP_TAG
COMPONENT design_ps_DataGen_3ch_0_1
  PORT (
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    hf_ch1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    hf_ch2 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    hf_ch3 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    trig_level_h_ch1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    trig_level_l_ch1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    trig_level_h_ch2 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    trig_level_l_ch2 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    trig_level_h_ch3 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    trig_level_l_ch3 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    pretrig : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    trig_length : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    dds_config_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    pulse_period : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    pulse_offset : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    pulse_width : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    adjusted_value : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    src_sel : IN STD_LOGIC;
    ch_sel : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    DataGen_ready : IN STD_LOGIC;
    hf_ch_send_flag : OUT STD_LOGIC;
    S_AXIS_start : IN STD_LOGIC;
    S_AXIS_aclk : OUT STD_LOGIC;
    S_AXIS_aresetn : OUT STD_LOGIC;
    S_AXIS_tready : IN STD_LOGIC;
    S_AXIS_tdata : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    S_AXIS_tkeep : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    S_AXIS_tvalid : OUT STD_LOGIC;
    S_AXIS_tlast : OUT STD_LOGIC
  );
END COMPONENT;
-- COMP_TAG_END ------ End COMPONENT Declaration ------------

-- The following code must appear in the VHDL architecture
-- body. Substitute your own instance name and net names.

------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
your_instance_name : design_ps_DataGen_3ch_0_1
  PORT MAP (
    clk => clk,
    rst => rst,
    hf_ch1 => hf_ch1,
    hf_ch2 => hf_ch2,
    hf_ch3 => hf_ch3,
    trig_level_h_ch1 => trig_level_h_ch1,
    trig_level_l_ch1 => trig_level_l_ch1,
    trig_level_h_ch2 => trig_level_h_ch2,
    trig_level_l_ch2 => trig_level_l_ch2,
    trig_level_h_ch3 => trig_level_h_ch3,
    trig_level_l_ch3 => trig_level_l_ch3,
    pretrig => pretrig,
    trig_length => trig_length,
    dds_config_data => dds_config_data,
    pulse_period => pulse_period,
    pulse_offset => pulse_offset,
    pulse_width => pulse_width,
    adjusted_value => adjusted_value,
    src_sel => src_sel,
    ch_sel => ch_sel,
    DataGen_ready => DataGen_ready,
    hf_ch_send_flag => hf_ch_send_flag,
    S_AXIS_start => S_AXIS_start,
    S_AXIS_aclk => S_AXIS_aclk,
    S_AXIS_aresetn => S_AXIS_aresetn,
    S_AXIS_tready => S_AXIS_tready,
    S_AXIS_tdata => S_AXIS_tdata,
    S_AXIS_tkeep => S_AXIS_tkeep,
    S_AXIS_tvalid => S_AXIS_tvalid,
    S_AXIS_tlast => S_AXIS_tlast
  );
-- INST_TAG_END ------ End INSTANTIATION Template ---------

-- You must compile the wrapper file design_ps_DataGen_3ch_0_1.vhd when simulating
-- the core, design_ps_DataGen_3ch_0_1. When compiling the wrapper file, be sure to
-- reference the VHDL simulation library.

