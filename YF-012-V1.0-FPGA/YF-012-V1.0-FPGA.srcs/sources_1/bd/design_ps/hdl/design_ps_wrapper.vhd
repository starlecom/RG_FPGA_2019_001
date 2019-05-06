--Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
--Date        : Thu Aug 23 16:09:00 2018
--Host        : WIN-F03HPCLQGPQ running 64-bit major release  (build 9200)
--Command     : generate_target design_ps_wrapper.bd
--Design      : design_ps_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_ps_wrapper is
  port (
    CH_EN1 : out STD_LOGIC_VECTOR ( 0 to 0 );
    CH_EN2 : out STD_LOGIC_VECTOR ( 0 to 0 );
    CH_EN3 : out STD_LOGIC_VECTOR ( 0 to 0 );
    DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_cas_n : inout STD_LOGIC;
    DDR_ck_n : inout STD_LOGIC;
    DDR_ck_p : inout STD_LOGIC;
    DDR_cke : inout STD_LOGIC;
    DDR_cs_n : inout STD_LOGIC;
    DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_odt : inout STD_LOGIC;
    DDR_ras_n : inout STD_LOGIC;
    DDR_reset_n : inout STD_LOGIC;
    DDR_we_n : inout STD_LOGIC;
    FIXED_IO_ddr_vrn : inout STD_LOGIC;
    FIXED_IO_ddr_vrp : inout STD_LOGIC;
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC;
    Vaux3_v_n : in STD_LOGIC;
    Vaux3_v_p : in STD_LOGIC;
    clk_n : in STD_LOGIC;
    clk_p : in STD_LOGIC;
    hf_ch1 : in STD_LOGIC_VECTOR ( 15 downto 0 );
    hf_ch2 : in STD_LOGIC_VECTOR ( 15 downto 0 );
    hf_ch3 : in STD_LOGIC_VECTOR ( 15 downto 0 );
    led : out STD_LOGIC_VECTOR ( 0 to 0 );
    uart_rt_rxd : in STD_LOGIC;
    uart_rt_txd : out STD_LOGIC
  );
end design_ps_wrapper;

architecture STRUCTURE of design_ps_wrapper is
  component design_ps is
  port (
    DDR_cas_n : inout STD_LOGIC;
    DDR_cke : inout STD_LOGIC;
    DDR_ck_n : inout STD_LOGIC;
    DDR_ck_p : inout STD_LOGIC;
    DDR_cs_n : inout STD_LOGIC;
    DDR_reset_n : inout STD_LOGIC;
    DDR_odt : inout STD_LOGIC;
    DDR_ras_n : inout STD_LOGIC;
    DDR_we_n : inout STD_LOGIC;
    DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ddr_vrn : inout STD_LOGIC;
    FIXED_IO_ddr_vrp : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC;
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC;
    Vaux3_v_n : in STD_LOGIC;
    Vaux3_v_p : in STD_LOGIC;
    uart_rt_rxd : in STD_LOGIC;
    uart_rt_txd : out STD_LOGIC;
    clk_p : in STD_LOGIC;
    clk_n : in STD_LOGIC;
    led : out STD_LOGIC_VECTOR ( 0 to 0 );
    hf_ch1 : in STD_LOGIC_VECTOR ( 15 downto 0 );
    hf_ch2 : in STD_LOGIC_VECTOR ( 15 downto 0 );
    hf_ch3 : in STD_LOGIC_VECTOR ( 15 downto 0 );
    CH_EN1 : out STD_LOGIC_VECTOR ( 0 to 0 );
    CH_EN3 : out STD_LOGIC_VECTOR ( 0 to 0 );
    CH_EN2 : out STD_LOGIC_VECTOR ( 0 to 0 )
  );
  end component design_ps;
begin
design_ps_i: component design_ps
     port map (
      CH_EN1(0) => CH_EN1(0),
      CH_EN2(0) => CH_EN2(0),
      CH_EN3(0) => CH_EN3(0),
      DDR_addr(14 downto 0) => DDR_addr(14 downto 0),
      DDR_ba(2 downto 0) => DDR_ba(2 downto 0),
      DDR_cas_n => DDR_cas_n,
      DDR_ck_n => DDR_ck_n,
      DDR_ck_p => DDR_ck_p,
      DDR_cke => DDR_cke,
      DDR_cs_n => DDR_cs_n,
      DDR_dm(3 downto 0) => DDR_dm(3 downto 0),
      DDR_dq(31 downto 0) => DDR_dq(31 downto 0),
      DDR_dqs_n(3 downto 0) => DDR_dqs_n(3 downto 0),
      DDR_dqs_p(3 downto 0) => DDR_dqs_p(3 downto 0),
      DDR_odt => DDR_odt,
      DDR_ras_n => DDR_ras_n,
      DDR_reset_n => DDR_reset_n,
      DDR_we_n => DDR_we_n,
      FIXED_IO_ddr_vrn => FIXED_IO_ddr_vrn,
      FIXED_IO_ddr_vrp => FIXED_IO_ddr_vrp,
      FIXED_IO_mio(53 downto 0) => FIXED_IO_mio(53 downto 0),
      FIXED_IO_ps_clk => FIXED_IO_ps_clk,
      FIXED_IO_ps_porb => FIXED_IO_ps_porb,
      FIXED_IO_ps_srstb => FIXED_IO_ps_srstb,
      Vaux3_v_n => Vaux3_v_n,
      Vaux3_v_p => Vaux3_v_p,
      clk_n => clk_n,
      clk_p => clk_p,
      hf_ch1(15 downto 0) => hf_ch1(15 downto 0),
      hf_ch2(15 downto 0) => hf_ch2(15 downto 0),
      hf_ch3(15 downto 0) => hf_ch3(15 downto 0),
      led(0) => led(0),
      uart_rt_rxd => uart_rt_rxd,
      uart_rt_txd => uart_rt_txd
    );
end STRUCTURE;
