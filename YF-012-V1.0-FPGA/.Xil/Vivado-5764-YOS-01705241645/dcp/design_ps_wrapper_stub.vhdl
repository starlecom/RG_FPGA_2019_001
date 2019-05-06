-- Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity design_ps_wrapper is
  Port ( 
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
    ch_en1_tri_o : out STD_LOGIC_VECTOR ( 0 to 0 );
    ch_en2_tri_o : out STD_LOGIC_VECTOR ( 0 to 0 );
    ch_en3_tri_o : out STD_LOGIC_VECTOR ( 0 to 0 );
    clk_n : in STD_LOGIC;
    clk_p : in STD_LOGIC;
    hf_ch1 : in STD_LOGIC_VECTOR ( 15 downto 0 );
    hf_ch2 : in STD_LOGIC_VECTOR ( 15 downto 0 );
    hf_ch3 : in STD_LOGIC_VECTOR ( 15 downto 0 );
    led : out STD_LOGIC_VECTOR ( 0 to 0 )
  );

end design_ps_wrapper;

architecture stub of design_ps_wrapper is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
begin
end;
