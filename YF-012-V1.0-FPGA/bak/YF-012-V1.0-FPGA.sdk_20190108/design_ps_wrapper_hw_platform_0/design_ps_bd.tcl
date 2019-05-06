
################################################################
# This is a generated script based on design: design_ps
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2015.4
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   puts "ERROR: This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source design_ps_script.tcl

# If you do not already have a project created,
# you can create a project using the following command:
#    create_project project_1 myproj -part xc7z020clg484-2

# CHECKING IF PROJECT EXISTS
if { [get_projects -quiet] eq "" } {
   puts "ERROR: Please open or create a project!"
   return 1
}



# CHANGE DESIGN NAME HERE
set design_name design_ps

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "ERROR: Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      puts "INFO: Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   puts "INFO: Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   puts "INFO: Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   puts "INFO: Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

puts "INFO: Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   puts $errMsg
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]
  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]
  set Vaux3 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux3 ]
  set uart_rt [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 uart_rt ]

  # Create ports
  set CH_EN1 [ create_bd_port -dir O -from 0 -to 0 CH_EN1 ]
  set CH_EN2 [ create_bd_port -dir O -from 0 -to 0 CH_EN2 ]
  set CH_EN3 [ create_bd_port -dir O -from 0 -to 0 CH_EN3 ]
  set clk_n [ create_bd_port -dir I -type clk clk_n ]
  set clk_p [ create_bd_port -dir I -type clk clk_p ]
  set hf_ch1 [ create_bd_port -dir I -from 15 -to 0 hf_ch1 ]
  set hf_ch2 [ create_bd_port -dir I -from 15 -to 0 hf_ch2 ]
  set hf_ch3 [ create_bd_port -dir I -from 15 -to 0 hf_ch3 ]
  set led [ create_bd_port -dir O -from 0 -to 0 led ]

  # Create instance: DataGen_3ch_0, and set properties
  set DataGen_3ch_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:DataGen_3ch:1.0 DataGen_3ch_0 ]

  # Create instance: Timer_10us_m_0, and set properties
  set Timer_10us_m_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:Timer_10us_m:1.0 Timer_10us_m_0 ]

  # Create instance: axi_dma_0, and set properties
  set axi_dma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_0 ]
  set_property -dict [ list \
CONFIG.c_include_mm2s {0} \
CONFIG.c_include_sg {0} \
CONFIG.c_sg_include_stscntrl_strm {0} \
CONFIG.c_sg_length_width {23} \
 ] $axi_dma_0

  # Create instance: axi_gpio_0, and set properties
  set axi_gpio_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0 ]
  set_property -dict [ list \
CONFIG.C_ALL_INPUTS {1} \
CONFIG.C_GPIO_WIDTH {1} \
 ] $axi_gpio_0

  # Create instance: axi_gpio_1, and set properties
  set axi_gpio_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_1 ]
  set_property -dict [ list \
CONFIG.C_ALL_INPUTS {0} \
CONFIG.C_ALL_OUTPUTS {1} \
CONFIG.C_GPIO_WIDTH {1} \
 ] $axi_gpio_1

  # Create instance: axi_gpio_2, and set properties
  set axi_gpio_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_2 ]
  set_property -dict [ list \
CONFIG.C_ALL_INPUTS {0} \
CONFIG.C_ALL_OUTPUTS {1} \
CONFIG.C_GPIO_WIDTH {16} \
 ] $axi_gpio_2

  # Create instance: axi_gpio_3, and set properties
  set axi_gpio_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_3 ]
  set_property -dict [ list \
CONFIG.C_ALL_INPUTS {0} \
CONFIG.C_ALL_OUTPUTS {1} \
CONFIG.C_GPIO_WIDTH {16} \
 ] $axi_gpio_3

  # Create instance: axi_gpio_4, and set properties
  set axi_gpio_4 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_4 ]
  set_property -dict [ list \
CONFIG.C_ALL_INPUTS {0} \
CONFIG.C_ALL_OUTPUTS {1} \
CONFIG.C_GPIO_WIDTH {16} \
 ] $axi_gpio_4

  # Create instance: axi_gpio_5, and set properties
  set axi_gpio_5 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_5 ]
  set_property -dict [ list \
CONFIG.C_ALL_INPUTS {0} \
CONFIG.C_ALL_OUTPUTS {1} \
CONFIG.C_GPIO_WIDTH {32} \
 ] $axi_gpio_5

  # Create instance: axi_gpio_6, and set properties
  set axi_gpio_6 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_6 ]
  set_property -dict [ list \
CONFIG.C_ALL_INPUTS {0} \
CONFIG.C_ALL_OUTPUTS {1} \
CONFIG.C_GPIO_WIDTH {16} \
 ] $axi_gpio_6

  # Create instance: axi_gpio_7, and set properties
  set axi_gpio_7 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_7 ]
  set_property -dict [ list \
CONFIG.C_ALL_INPUTS {0} \
CONFIG.C_ALL_OUTPUTS {1} \
CONFIG.C_GPIO_WIDTH {16} \
 ] $axi_gpio_7

  # Create instance: axi_gpio_8, and set properties
  set axi_gpio_8 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_8 ]
  set_property -dict [ list \
CONFIG.C_ALL_INPUTS {0} \
CONFIG.C_ALL_OUTPUTS {1} \
CONFIG.C_GPIO_WIDTH {16} \
 ] $axi_gpio_8

  # Create instance: axi_gpio_9, and set properties
  set axi_gpio_9 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_9 ]
  set_property -dict [ list \
CONFIG.C_ALL_INPUTS {0} \
CONFIG.C_ALL_OUTPUTS {1} \
CONFIG.C_GPIO_WIDTH {1} \
 ] $axi_gpio_9

  # Create instance: axi_gpio_10, and set properties
  set axi_gpio_10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_10 ]
  set_property -dict [ list \
CONFIG.C_ALL_INPUTS {0} \
CONFIG.C_ALL_OUTPUTS {1} \
CONFIG.C_GPIO_WIDTH {1} \
 ] $axi_gpio_10

  # Create instance: axi_gpio_11, and set properties
  set axi_gpio_11 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_11 ]
  set_property -dict [ list \
CONFIG.C_ALL_INPUTS {0} \
CONFIG.C_ALL_OUTPUTS {1} \
CONFIG.C_GPIO_WIDTH {1} \
 ] $axi_gpio_11

  # Create instance: axi_gpio_12, and set properties
  set axi_gpio_12 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_12 ]
  set_property -dict [ list \
CONFIG.C_ALL_INPUTS {0} \
CONFIG.C_ALL_OUTPUTS {1} \
CONFIG.C_GPIO_WIDTH {4} \
 ] $axi_gpio_12

  # Create instance: axi_gpio_13, and set properties
  set axi_gpio_13 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_13 ]
  set_property -dict [ list \
CONFIG.C_ALL_OUTPUTS {1} \
CONFIG.C_GPIO_WIDTH {1} \
 ] $axi_gpio_13

  # Create instance: axi_gpio_14, and set properties
  set axi_gpio_14 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_14 ]
  set_property -dict [ list \
CONFIG.C_ALL_OUTPUTS {1} \
CONFIG.C_GPIO_WIDTH {1} \
 ] $axi_gpio_14

  # Create instance: axi_gpio_15, and set properties
  set axi_gpio_15 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_15 ]
  set_property -dict [ list \
CONFIG.C_ALL_OUTPUTS {1} \
CONFIG.C_GPIO_WIDTH {1} \
 ] $axi_gpio_15

  # Create instance: axi_gpio_16, and set properties
  set axi_gpio_16 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_16 ]
  set_property -dict [ list \
CONFIG.C_ALL_OUTPUTS {1} \
CONFIG.C_GPIO_WIDTH {16} \
 ] $axi_gpio_16

  # Create instance: axi_gpio_17, and set properties
  set axi_gpio_17 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_17 ]
  set_property -dict [ list \
CONFIG.C_ALL_OUTPUTS {1} \
CONFIG.C_GPIO_WIDTH {16} \
 ] $axi_gpio_17

  # Create instance: axi_gpio_18, and set properties
  set axi_gpio_18 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_18 ]
  set_property -dict [ list \
CONFIG.C_ALL_INPUTS {0} \
CONFIG.C_ALL_OUTPUTS {1} \
CONFIG.C_GPIO_WIDTH {16} \
 ] $axi_gpio_18

  # Create instance: axi_gpio_19, and set properties
  set axi_gpio_19 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_19 ]
  set_property -dict [ list \
CONFIG.C_ALL_INPUTS {0} \
CONFIG.C_ALL_OUTPUTS {1} \
CONFIG.C_GPIO_WIDTH {16} \
 ] $axi_gpio_19

  # Create instance: axi_gpio_20, and set properties
  set axi_gpio_20 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_20 ]
  set_property -dict [ list \
CONFIG.C_ALL_INPUTS {0} \
CONFIG.C_ALL_OUTPUTS {1} \
CONFIG.C_GPIO_WIDTH {16} \
 ] $axi_gpio_20

  # Create instance: axi_gpio_21, and set properties
  set axi_gpio_21 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_21 ]
  set_property -dict [ list \
CONFIG.C_ALL_INPUTS {0} \
CONFIG.C_ALL_OUTPUTS {1} \
CONFIG.C_GPIO_WIDTH {16} \
 ] $axi_gpio_21

  # Create instance: axi_mem_intercon, and set properties
  set axi_mem_intercon [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_mem_intercon ]
  set_property -dict [ list \
CONFIG.NUM_MI {1} \
CONFIG.NUM_SI {2} \
 ] $axi_mem_intercon

  # Create instance: axi_uartlite_0, and set properties
  set axi_uartlite_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uartlite_0 ]
  set_property -dict [ list \
CONFIG.C_BAUDRATE {9600} \
 ] $axi_uartlite_0

  # Create instance: axis_data_fifo_0, and set properties
  set axis_data_fifo_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:1.1 axis_data_fifo_0 ]
  set_property -dict [ list \
CONFIG.FIFO_DEPTH {4096} \
CONFIG.HAS_TKEEP {1} \
CONFIG.IS_ACLK_ASYNC {1} \
 ] $axis_data_fifo_0

  # Create instance: clk_wiz_0, and set properties
  set clk_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:5.2 clk_wiz_0 ]
  set_property -dict [ list \
CONFIG.PRIM_IN_FREQ {100.000} \
CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} \
CONFIG.USE_LOCKED {false} \
CONFIG.USE_RESET {false} \
 ] $clk_wiz_0

  # Create instance: processing_system7_0, and set properties
  set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0 ]
  set_property -dict [ list \
CONFIG.PCW_CORE1_IRQ_INTR {1} \
CONFIG.PCW_ENET0_ENET0_IO {MIO 16 .. 27} \
CONFIG.PCW_ENET0_GRP_MDIO_ENABLE {1} \
CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_EN_CLK0_PORT {1} \
CONFIG.PCW_EN_CLK1_PORT {1} \
CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {100} \
CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {100} \
CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {1} \
CONFIG.PCW_GPIO_MIO_GPIO_IO {MIO} \
CONFIG.PCW_IRQ_F2P_INTR {1} \
CONFIG.PCW_PRESET_BANK1_VOLTAGE {LVCMOS 1.8V} \
CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1} \
CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_QSPI_QSPI_IO {MIO 1 .. 6} \
CONFIG.PCW_SD0_GRP_CD_ENABLE {1} \
CONFIG.PCW_SD0_GRP_CD_IO {MIO 47} \
CONFIG.PCW_SD0_GRP_WP_ENABLE {1} \
CONFIG.PCW_SD0_GRP_WP_IO {MIO 46} \
CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_SD0_SD0_IO {MIO 40 .. 45} \
CONFIG.PCW_SDIO_PERIPHERAL_FREQMHZ {50} \
CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_UIPARAM_DDR_PARTNO {MT41K256M16 RE-125} \
CONFIG.PCW_USE_FABRIC_INTERRUPT {1} \
CONFIG.PCW_USE_S_AXI_HP0 {1} \
 ] $processing_system7_0

  # Create instance: processing_system7_0_axi_periph, and set properties
  set processing_system7_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 processing_system7_0_axi_periph ]
  set_property -dict [ list \
CONFIG.NUM_MI {25} \
 ] $processing_system7_0_axi_periph

  # Create instance: rst_processing_system7_0_100M, and set properties
  set rst_processing_system7_0_100M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_processing_system7_0_100M ]

  # Create instance: xadc_wiz_0, and set properties
  set xadc_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xadc_wiz:3.2 xadc_wiz_0 ]
  set_property -dict [ list \
CONFIG.ADC_OFFSET_AND_GAIN_CALIBRATION {true} \
CONFIG.AVERAGE_ENABLE_TEMPERATURE {false} \
CONFIG.AVERAGE_ENABLE_VAUXP3_VAUXN3 {false} \
CONFIG.AVERAGE_ENABLE_VCCINT {false} \
CONFIG.AVERAGE_ENABLE_VP_VN {false} \
CONFIG.CHANNEL_AVERAGING {16} \
CONFIG.CHANNEL_ENABLE_CALIBRATION {false} \
CONFIG.CHANNEL_ENABLE_TEMPERATURE {false} \
CONFIG.CHANNEL_ENABLE_VAUXP3_VAUXN3 {false} \
CONFIG.CHANNEL_ENABLE_VCCINT {false} \
CONFIG.CHANNEL_ENABLE_VP_VN {false} \
CONFIG.ENABLE_VCCDDRO_ALARM {false} \
CONFIG.ENABLE_VCCPAUX_ALARM {false} \
CONFIG.ENABLE_VCCPINT_ALARM {false} \
CONFIG.EXTERNAL_MUX_CHANNEL {VP_VN} \
CONFIG.OT_ALARM {false} \
CONFIG.SENSOR_OFFSET_AND_GAIN_CALIBRATION {true} \
CONFIG.SEQUENCER_MODE {Off} \
CONFIG.SINGLE_CHANNEL_SELECTION {VAUXP3_VAUXN3} \
CONFIG.USER_TEMP_ALARM {false} \
CONFIG.VCCAUX_ALARM {false} \
CONFIG.VCCINT_ALARM {false} \
CONFIG.VCCINT_ALARM_LOWER {0.97} \
CONFIG.VCCINT_ALARM_UPPER {1.03} \
CONFIG.XADC_STARUP_SELECTION {single_channel} \
 ] $xadc_wiz_0

  # Create instance: xlconstant_3, and set properties
  set xlconstant_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_3 ]
  set_property -dict [ list \
CONFIG.CONST_VAL {1} \
CONFIG.CONST_WIDTH {1} \
 ] $xlconstant_3

  # Create interface connections
  connect_bd_intf_net -intf_net DataGen_3ch_0_S_AXIS [get_bd_intf_pins DataGen_3ch_0/S_AXIS] [get_bd_intf_pins axis_data_fifo_0/S_AXIS]
  set_property -dict [ list \
HDL_ATTRIBUTE.MARK_DEBUG {true} \
HDL_ATTRIBUTE.DEBUG_IN_BD {true} \
 ] [get_bd_intf_nets DataGen_3ch_0_S_AXIS]
  connect_bd_intf_net -intf_net Vaux3_1 [get_bd_intf_ports Vaux3] [get_bd_intf_pins xadc_wiz_0/Vaux3]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_S2MM [get_bd_intf_pins axi_dma_0/M_AXI_S2MM] [get_bd_intf_pins axi_mem_intercon/S00_AXI]
  connect_bd_intf_net -intf_net axi_mem_intercon_M00_AXI [get_bd_intf_pins axi_mem_intercon/M00_AXI] [get_bd_intf_pins processing_system7_0/S_AXI_HP0]
  connect_bd_intf_net -intf_net axi_uartlite_0_UART [get_bd_intf_ports uart_rt] [get_bd_intf_pins axi_uartlite_0/UART]
  connect_bd_intf_net -intf_net axis_data_fifo_0_M_AXIS [get_bd_intf_pins axi_dma_0/S_AXIS_S2MM] [get_bd_intf_pins axis_data_fifo_0/M_AXIS]
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins processing_system7_0/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]
  connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP0 [get_bd_intf_pins processing_system7_0/M_AXI_GP0] [get_bd_intf_pins processing_system7_0_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M00_AXI [get_bd_intf_pins axi_dma_0/S_AXI_LITE] [get_bd_intf_pins processing_system7_0_axi_periph/M00_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M01_AXI [get_bd_intf_pins axi_gpio_0/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M01_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M02_AXI [get_bd_intf_pins axi_gpio_1/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M02_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M03_AXI [get_bd_intf_pins axi_gpio_2/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M03_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M04_AXI [get_bd_intf_pins axi_gpio_3/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M04_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M05_AXI [get_bd_intf_pins axi_gpio_4/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M05_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M06_AXI [get_bd_intf_pins axi_gpio_5/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M06_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M07_AXI [get_bd_intf_pins axi_gpio_6/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M07_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M08_AXI [get_bd_intf_pins axi_gpio_7/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M08_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M09_AXI [get_bd_intf_pins axi_gpio_8/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M09_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M10_AXI [get_bd_intf_pins axi_gpio_9/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M10_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M11_AXI [get_bd_intf_pins axi_gpio_10/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M11_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M12_AXI [get_bd_intf_pins axi_gpio_11/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M12_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M13_AXI [get_bd_intf_pins axi_gpio_12/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M13_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M14_AXI [get_bd_intf_pins processing_system7_0_axi_periph/M14_AXI] [get_bd_intf_pins xadc_wiz_0/s_axi_lite]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M15_AXI [get_bd_intf_pins axi_gpio_13/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M15_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M16_AXI [get_bd_intf_pins axi_gpio_14/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M16_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M17_AXI [get_bd_intf_pins axi_gpio_15/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M17_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M18_AXI [get_bd_intf_pins axi_uartlite_0/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M18_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M19_AXI [get_bd_intf_pins axi_gpio_16/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M19_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M20_AXI [get_bd_intf_pins axi_gpio_17/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M20_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M21_AXI [get_bd_intf_pins axi_gpio_18/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M21_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M22_AXI [get_bd_intf_pins axi_gpio_19/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M22_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M23_AXI [get_bd_intf_pins axi_gpio_20/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M23_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M24_AXI [get_bd_intf_pins axi_gpio_21/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M24_AXI]

  # Create port connections
  connect_bd_net -net DataGen_3ch_0_S_AXIS_aclk [get_bd_pins DataGen_3ch_0/S_AXIS_aclk] [get_bd_pins axis_data_fifo_0/s_axis_aclk]
  connect_bd_net -net DataGen_3ch_0_S_AXIS_aresetn [get_bd_pins DataGen_3ch_0/S_AXIS_aresetn] [get_bd_pins axis_data_fifo_0/s_axis_aresetn]
  connect_bd_net -net DataGen_3ch_0_hf_ch_send_flag [get_bd_pins DataGen_3ch_0/hf_ch_send_flag] [get_bd_pins axi_gpio_0/gpio_io_i]
  set_property -dict [ list \
HDL_ATTRIBUTE.MARK_DEBUG {true} \
HDL_ATTRIBUTE.DEBUG_IN_BD {true} \
 ] [get_bd_nets DataGen_3ch_0_hf_ch_send_flag]
  connect_bd_net -net Timer_10us_m_0_timer_10us_o [get_bd_pins Timer_10us_m_0/timer_10us_o] [get_bd_pins processing_system7_0/Core1_nIRQ]
  connect_bd_net -net axi_dma_0_s2mm_introut [get_bd_pins axi_dma_0/s2mm_introut] [get_bd_pins processing_system7_0/IRQ_F2P]
  connect_bd_net -net axi_gpio_10_gpio_io_o [get_bd_pins DataGen_3ch_0/DataGen_ready] [get_bd_pins axi_gpio_10/gpio_io_o]
  connect_bd_net -net axi_gpio_11_gpio_io_o [get_bd_ports led] [get_bd_pins axi_gpio_11/gpio_io_o]
  connect_bd_net -net axi_gpio_12_gpio_io_o [get_bd_pins DataGen_3ch_0/ch_sel] [get_bd_pins axi_gpio_12/gpio_io_o]
  connect_bd_net -net axi_gpio_13_gpio_io_o [get_bd_ports CH_EN1] [get_bd_pins axi_gpio_13/gpio_io_o]
  connect_bd_net -net axi_gpio_14_gpio_io_o [get_bd_ports CH_EN2] [get_bd_pins axi_gpio_14/gpio_io_o]
  connect_bd_net -net axi_gpio_15_gpio_io_o [get_bd_ports CH_EN3] [get_bd_pins axi_gpio_15/gpio_io_o]
  connect_bd_net -net axi_gpio_16_gpio_io_o [get_bd_pins DataGen_3ch_0/adjusted_value] [get_bd_pins axi_gpio_16/gpio_io_o]
  connect_bd_net -net axi_gpio_17_gpio_io_o [get_bd_pins DataGen_3ch_0/trig_level_l_ch1] [get_bd_pins axi_gpio_17/gpio_io_o]
  connect_bd_net -net axi_gpio_18_gpio_io_o [get_bd_pins DataGen_3ch_0/trig_level_h_ch3] [get_bd_pins axi_gpio_18/gpio_io_o]
  connect_bd_net -net axi_gpio_19_gpio_io_o [get_bd_pins DataGen_3ch_0/trig_level_l_ch2] [get_bd_pins axi_gpio_19/gpio_io_o]
  connect_bd_net -net axi_gpio_1_gpio_io_o [get_bd_pins DataGen_3ch_0/S_AXIS_start] [get_bd_pins axi_gpio_1/gpio_io_o]
  connect_bd_net -net axi_gpio_20_gpio_io_o [get_bd_pins DataGen_3ch_0/trig_level_l_ch3] [get_bd_pins axi_gpio_20/gpio_io_o]
  connect_bd_net -net axi_gpio_21_gpio_io_o [get_bd_pins DataGen_3ch_0/trig_level_h_ch2] [get_bd_pins axi_gpio_21/gpio_io_o]
  connect_bd_net -net axi_gpio_2_gpio_io_o [get_bd_pins DataGen_3ch_0/trig_level_h_ch1] [get_bd_pins axi_gpio_2/gpio_io_o]
  connect_bd_net -net axi_gpio_3_gpio_io_o [get_bd_pins DataGen_3ch_0/pretrig] [get_bd_pins axi_gpio_3/gpio_io_o]
  connect_bd_net -net axi_gpio_4_gpio_io_o [get_bd_pins DataGen_3ch_0/trig_length] [get_bd_pins axi_gpio_4/gpio_io_o]
  connect_bd_net -net axi_gpio_5_gpio_io_o [get_bd_pins DataGen_3ch_0/dds_config_data] [get_bd_pins axi_gpio_5/gpio_io_o]
  connect_bd_net -net axi_gpio_6_gpio_io_o [get_bd_pins DataGen_3ch_0/pulse_period] [get_bd_pins axi_gpio_6/gpio_io_o]
  connect_bd_net -net axi_gpio_7_gpio_io_o [get_bd_pins DataGen_3ch_0/pulse_offset] [get_bd_pins axi_gpio_7/gpio_io_o]
  connect_bd_net -net axi_gpio_8_gpio_io_o [get_bd_pins DataGen_3ch_0/pulse_width] [get_bd_pins axi_gpio_8/gpio_io_o]
  connect_bd_net -net axi_gpio_9_gpio_io_o [get_bd_pins DataGen_3ch_0/src_sel] [get_bd_pins axi_gpio_9/gpio_io_o]
  connect_bd_net -net clk_n_1 [get_bd_ports clk_n] [get_bd_pins clk_wiz_0/clk_in1_n]
  connect_bd_net -net clk_p_1 [get_bd_ports clk_p] [get_bd_pins clk_wiz_0/clk_in1_p]
  connect_bd_net -net clk_wiz_0_clk_out1 [get_bd_pins DataGen_3ch_0/clk] [get_bd_pins Timer_10us_m_0/clk_i] [get_bd_pins clk_wiz_0/clk_out1]
  connect_bd_net -net hf_ch1_1 [get_bd_ports hf_ch1] [get_bd_pins DataGen_3ch_0/hf_ch1]
  connect_bd_net -net hf_ch2_1 [get_bd_ports hf_ch2] [get_bd_pins DataGen_3ch_0/hf_ch2]
  connect_bd_net -net hf_ch3_1 [get_bd_ports hf_ch3] [get_bd_pins DataGen_3ch_0/hf_ch3]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins axi_dma_0/m_axi_s2mm_aclk] [get_bd_pins axi_dma_0/s_axi_lite_aclk] [get_bd_pins axi_gpio_0/s_axi_aclk] [get_bd_pins axi_gpio_1/s_axi_aclk] [get_bd_pins axi_gpio_10/s_axi_aclk] [get_bd_pins axi_gpio_11/s_axi_aclk] [get_bd_pins axi_gpio_12/s_axi_aclk] [get_bd_pins axi_gpio_13/s_axi_aclk] [get_bd_pins axi_gpio_14/s_axi_aclk] [get_bd_pins axi_gpio_15/s_axi_aclk] [get_bd_pins axi_gpio_16/s_axi_aclk] [get_bd_pins axi_gpio_17/s_axi_aclk] [get_bd_pins axi_gpio_18/s_axi_aclk] [get_bd_pins axi_gpio_19/s_axi_aclk] [get_bd_pins axi_gpio_2/s_axi_aclk] [get_bd_pins axi_gpio_20/s_axi_aclk] [get_bd_pins axi_gpio_21/s_axi_aclk] [get_bd_pins axi_gpio_3/s_axi_aclk] [get_bd_pins axi_gpio_4/s_axi_aclk] [get_bd_pins axi_gpio_5/s_axi_aclk] [get_bd_pins axi_gpio_6/s_axi_aclk] [get_bd_pins axi_gpio_7/s_axi_aclk] [get_bd_pins axi_gpio_8/s_axi_aclk] [get_bd_pins axi_gpio_9/s_axi_aclk] [get_bd_pins axi_mem_intercon/ACLK] [get_bd_pins axi_mem_intercon/M00_ACLK] [get_bd_pins axi_mem_intercon/S00_ACLK] [get_bd_pins axi_mem_intercon/S01_ACLK] [get_bd_pins axi_uartlite_0/s_axi_aclk] [get_bd_pins axis_data_fifo_0/m_axis_aclk] [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins processing_system7_0/S_AXI_HP0_ACLK] [get_bd_pins processing_system7_0_axi_periph/ACLK] [get_bd_pins processing_system7_0_axi_periph/M00_ACLK] [get_bd_pins processing_system7_0_axi_periph/M01_ACLK] [get_bd_pins processing_system7_0_axi_periph/M02_ACLK] [get_bd_pins processing_system7_0_axi_periph/M03_ACLK] [get_bd_pins processing_system7_0_axi_periph/M04_ACLK] [get_bd_pins processing_system7_0_axi_periph/M05_ACLK] [get_bd_pins processing_system7_0_axi_periph/M06_ACLK] [get_bd_pins processing_system7_0_axi_periph/M07_ACLK] [get_bd_pins processing_system7_0_axi_periph/M08_ACLK] [get_bd_pins processing_system7_0_axi_periph/M09_ACLK] [get_bd_pins processing_system7_0_axi_periph/M10_ACLK] [get_bd_pins processing_system7_0_axi_periph/M11_ACLK] [get_bd_pins processing_system7_0_axi_periph/M12_ACLK] [get_bd_pins processing_system7_0_axi_periph/M13_ACLK] [get_bd_pins processing_system7_0_axi_periph/M14_ACLK] [get_bd_pins processing_system7_0_axi_periph/M15_ACLK] [get_bd_pins processing_system7_0_axi_periph/M16_ACLK] [get_bd_pins processing_system7_0_axi_periph/M17_ACLK] [get_bd_pins processing_system7_0_axi_periph/M18_ACLK] [get_bd_pins processing_system7_0_axi_periph/M19_ACLK] [get_bd_pins processing_system7_0_axi_periph/M20_ACLK] [get_bd_pins processing_system7_0_axi_periph/M21_ACLK] [get_bd_pins processing_system7_0_axi_periph/M22_ACLK] [get_bd_pins processing_system7_0_axi_periph/M23_ACLK] [get_bd_pins processing_system7_0_axi_periph/M24_ACLK] [get_bd_pins processing_system7_0_axi_periph/S00_ACLK] [get_bd_pins rst_processing_system7_0_100M/slowest_sync_clk] [get_bd_pins xadc_wiz_0/s_axi_aclk]
  connect_bd_net -net processing_system7_0_FCLK_RESET0_N [get_bd_pins processing_system7_0/FCLK_RESET0_N] [get_bd_pins rst_processing_system7_0_100M/ext_reset_in]
  connect_bd_net -net rst_processing_system7_0_100M_interconnect_aresetn [get_bd_pins axi_mem_intercon/ARESETN] [get_bd_pins processing_system7_0_axi_periph/ARESETN] [get_bd_pins rst_processing_system7_0_100M/interconnect_aresetn]
  connect_bd_net -net rst_processing_system7_0_100M_peripheral_aresetn [get_bd_pins axi_dma_0/axi_resetn] [get_bd_pins axi_gpio_0/s_axi_aresetn] [get_bd_pins axi_gpio_1/s_axi_aresetn] [get_bd_pins axi_gpio_10/s_axi_aresetn] [get_bd_pins axi_gpio_11/s_axi_aresetn] [get_bd_pins axi_gpio_12/s_axi_aresetn] [get_bd_pins axi_gpio_13/s_axi_aresetn] [get_bd_pins axi_gpio_14/s_axi_aresetn] [get_bd_pins axi_gpio_15/s_axi_aresetn] [get_bd_pins axi_gpio_16/s_axi_aresetn] [get_bd_pins axi_gpio_17/s_axi_aresetn] [get_bd_pins axi_gpio_18/s_axi_aresetn] [get_bd_pins axi_gpio_19/s_axi_aresetn] [get_bd_pins axi_gpio_2/s_axi_aresetn] [get_bd_pins axi_gpio_20/s_axi_aresetn] [get_bd_pins axi_gpio_21/s_axi_aresetn] [get_bd_pins axi_gpio_3/s_axi_aresetn] [get_bd_pins axi_gpio_4/s_axi_aresetn] [get_bd_pins axi_gpio_5/s_axi_aresetn] [get_bd_pins axi_gpio_6/s_axi_aresetn] [get_bd_pins axi_gpio_7/s_axi_aresetn] [get_bd_pins axi_gpio_8/s_axi_aresetn] [get_bd_pins axi_gpio_9/s_axi_aresetn] [get_bd_pins axi_mem_intercon/M00_ARESETN] [get_bd_pins axi_mem_intercon/S00_ARESETN] [get_bd_pins axi_mem_intercon/S01_ARESETN] [get_bd_pins axi_uartlite_0/s_axi_aresetn] [get_bd_pins axis_data_fifo_0/m_axis_aresetn] [get_bd_pins processing_system7_0_axi_periph/M00_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M01_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M02_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M03_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M04_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M05_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M06_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M07_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M08_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M09_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M10_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M11_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M12_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M13_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M14_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M15_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M16_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M17_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M18_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M19_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M20_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M21_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M22_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M23_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M24_ARESETN] [get_bd_pins processing_system7_0_axi_periph/S00_ARESETN] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn] [get_bd_pins xadc_wiz_0/s_axi_aresetn]
  connect_bd_net -net xlconstant_3_dout [get_bd_pins DataGen_3ch_0/rst] [get_bd_pins xlconstant_3/dout]

  # Create address segments
  create_bd_addr_seg -range 0x40000000 -offset 0x0 [get_bd_addr_spaces axi_dma_0/Data_S2MM] [get_bd_addr_segs processing_system7_0/S_AXI_HP0/HP0_DDR_LOWOCM] SEG_processing_system7_0_HP0_DDR_LOWOCM
  create_bd_addr_seg -range 0x10000 -offset 0x40400000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_dma_0/S_AXI_LITE/Reg] SEG_axi_dma_0_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x41200000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_gpio_0/S_AXI/Reg] SEG_axi_gpio_0_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x412A0000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_gpio_10/S_AXI/Reg] SEG_axi_gpio_10_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x412B0000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_gpio_11/S_AXI/Reg] SEG_axi_gpio_11_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x412C0000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_gpio_12/S_AXI/Reg] SEG_axi_gpio_12_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x412D0000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_gpio_13/S_AXI/Reg] SEG_axi_gpio_13_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x412F0000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_gpio_14/S_AXI/Reg] SEG_axi_gpio_14_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x412E0000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_gpio_15/S_AXI/Reg] SEG_axi_gpio_15_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x41300000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_gpio_16/S_AXI/Reg] SEG_axi_gpio_16_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x41310000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_gpio_17/S_AXI/Reg] SEG_axi_gpio_17_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x41320000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_gpio_18/S_AXI/Reg] SEG_axi_gpio_18_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x41330000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_gpio_19/S_AXI/Reg] SEG_axi_gpio_19_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x41210000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_gpio_1/S_AXI/Reg] SEG_axi_gpio_1_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x41340000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_gpio_20/S_AXI/Reg] SEG_axi_gpio_20_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x41350000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_gpio_21/S_AXI/Reg] SEG_axi_gpio_21_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x41220000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_gpio_2/S_AXI/Reg] SEG_axi_gpio_2_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x41230000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_gpio_3/S_AXI/Reg] SEG_axi_gpio_3_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x41240000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_gpio_4/S_AXI/Reg] SEG_axi_gpio_4_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x41250000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_gpio_5/S_AXI/Reg] SEG_axi_gpio_5_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x41260000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_gpio_6/S_AXI/Reg] SEG_axi_gpio_6_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x41270000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_gpio_7/S_AXI/Reg] SEG_axi_gpio_7_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x41280000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_gpio_8/S_AXI/Reg] SEG_axi_gpio_8_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x41290000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_gpio_9/S_AXI/Reg] SEG_axi_gpio_9_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x42C00000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_uartlite_0/S_AXI/Reg] SEG_axi_uartlite_0_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x43C00000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs xadc_wiz_0/s_axi_lite/Reg] SEG_xadc_wiz_0_Reg

  # Perform GUI Layout
  regenerate_bd_layout -layout_string {
   guistr: "# # String gsaved with Nlview 6.5.5  2015-06-26 bk=1.3371 VDI=38 GEI=35 GUI=JA:1.6
#  -string -flagsOSRD
preplace port DDR -pg 1 -y 2360 -defaultsOSRD
preplace port clk_n -pg 1 -y 1160 -defaultsOSRD
preplace port clk_p -pg 1 -y 1180 -defaultsOSRD
preplace port Vaux3 -pg 1 -y 2760 -defaultsOSRD
preplace port uart_rt -pg 1 -y 2020 -defaultsOSRD
preplace port FIXED_IO -pg 1 -y 2380 -defaultsOSRD
preplace portBus hf_ch1 -pg 1 -y 1070 -defaultsOSRD
preplace portBus CH_EN1 -pg 1 -y 1560 -defaultsOSRD
preplace portBus hf_ch2 -pg 1 -y 1090 -defaultsOSRD
preplace portBus CH_EN2 -pg 1 -y 1680 -defaultsOSRD
preplace portBus hf_ch3 -pg 1 -y 1310 -defaultsOSRD
preplace portBus CH_EN3 -pg 1 -y 1800 -defaultsOSRD
preplace portBus led -pg 1 -y 1920 -defaultsOSRD
preplace inst axi_gpio_10 -pg 1 -lvl 8 -y 1600 -defaultsOSRD
preplace inst axi_gpio_8 -pg 1 -lvl 8 -y 2230 -defaultsOSRD
preplace inst axi_gpio_11 -pg 1 -lvl 9 -y 1910 -defaultsOSRD
preplace inst axi_gpio_9 -pg 1 -lvl 8 -y 2470 -defaultsOSRD
preplace inst axi_dma_0 -pg 1 -lvl 4 -y 1240 -defaultsOSRD
preplace inst axi_gpio_12 -pg 1 -lvl 8 -y 1740 -defaultsOSRD
preplace inst rst_processing_system7_0_100M -pg 1 -lvl 2 -y 1600 -defaultsOSRD
preplace inst axi_gpio_13 -pg 1 -lvl 9 -y 1550 -defaultsOSRD
preplace inst xadc_wiz_0 -pg 1 -lvl 8 -y 2760 -defaultsOSRD
preplace inst axi_gpio_14 -pg 1 -lvl 9 -y 1670 -defaultsOSRD
preplace inst axi_gpio_15 -pg 1 -lvl 9 -y 1790 -defaultsOSRD
preplace inst xlconstant_3 -pg 1 -lvl 1 -y 1260 -defaultsOSRD
preplace inst axi_gpio_0 -pg 1 -lvl 8 -y 1040 -defaultsOSRD
preplace inst axi_gpio_16 -pg 1 -lvl 8 -y 1920 -defaultsOSRD
preplace inst axi_gpio_1 -pg 1 -lvl 8 -y 1180 -defaultsOSRD
preplace inst axi_gpio_17 -pg 1 -lvl 8 -y 620 -defaultsOSRD
preplace inst axi_gpio_2 -pg 1 -lvl 8 -y 60 -defaultsOSRD
preplace inst axi_gpio_18 -pg 1 -lvl 8 -y 340 -defaultsOSRD
preplace inst axi_gpio_3 -pg 1 -lvl 8 -y 200 -defaultsOSRD
preplace inst axi_gpio_19 -pg 1 -lvl 8 -y 760 -defaultsOSRD
preplace inst axi_uartlite_0 -pg 1 -lvl 9 -y 2030 -defaultsOSRD
preplace inst axi_gpio_4 -pg 1 -lvl 8 -y 480 -defaultsOSRD
preplace inst clk_wiz_0 -pg 1 -lvl 1 -y 1160 -defaultsOSRD
preplace inst axi_gpio_5 -pg 1 -lvl 8 -y 1320 -defaultsOSRD
preplace inst axi_gpio_20 -pg 1 -lvl 8 -y 900 -defaultsOSRD
preplace inst axi_gpio_6 -pg 1 -lvl 8 -y 1460 -defaultsOSRD
preplace inst axi_mem_intercon -pg 1 -lvl 5 -y 1340 -defaultsOSRD
preplace inst DataGen_3ch_0 -pg 1 -lvl 2 -y 1240 -defaultsOSRD
preplace inst axi_gpio_21 -pg 1 -lvl 8 -y 2590 -defaultsOSRD
preplace inst Timer_10us_m_0 -pg 1 -lvl 5 -y 2460 -defaultsOSRD
preplace inst axi_gpio_7 -pg 1 -lvl 8 -y 2090 -defaultsOSRD
preplace inst processing_system7_0_axi_periph -pg 1 -lvl 7 -y 1730 -defaultsOSRD
preplace inst axis_data_fifo_0 -pg 1 -lvl 3 -y 1250 -defaultsOSRD
preplace inst processing_system7_0 -pg 1 -lvl 6 -y 2410 -defaultsOSRD
preplace netloc axi_gpio_6_gpio_io_o 1 1 8 330 2140 NJ 2140 NJ 2140 NJ 2140 NJ 2140 NJ 2340 NJ 2340 3020
preplace netloc axi_gpio_13_gpio_io_o 1 9 1 NJ
preplace netloc axi_gpio_20_gpio_io_o 1 1 8 380 960 NJ 960 NJ 960 NJ 960 NJ 960 NJ 960 NJ 970 3080
preplace netloc axi_gpio_14_gpio_io_o 1 9 1 NJ
preplace netloc hf_ch2_1 1 0 2 NJ 1080 NJ
preplace netloc processing_system7_0_axi_periph_M08_AXI 1 7 1 2640
preplace netloc processing_system7_0_FIXED_IO 1 6 4 NJ 2400 NJ 2400 NJ 2380 NJ
preplace netloc axi_gpio_1_gpio_io_o 1 1 8 300 930 NJ 930 NJ 930 NJ 930 NJ 930 NJ 930 NJ 1250 3080
preplace netloc processing_system7_0_axi_periph_M17_AXI 1 7 2 NJ 1830 3080
preplace netloc xlconstant_3_dout 1 1 1 NJ
preplace netloc hf_ch1_1 1 0 2 NJ 1070 NJ
preplace netloc processing_system7_0_axi_periph_M24_AXI 1 7 1 2530
preplace netloc DataGen_3ch_0_S_AXIS 1 2 1 N
preplace netloc axi_gpio_18_gpio_io_o 1 1 8 290 270 NJ 270 NJ 270 NJ 270 NJ 270 NJ 270 NJ 270 3080
preplace netloc axi_gpio_3_gpio_io_o 1 1 8 270 130 NJ 130 NJ 130 NJ 130 NJ 130 NJ 130 NJ 130 3080
preplace netloc axi_gpio_9_gpio_io_o 1 1 8 360 2160 NJ 2160 NJ 2160 NJ 2160 NJ 2160 NJ 2350 NJ 2350 2990
preplace netloc processing_system7_0_axi_periph_M18_AXI 1 7 2 N 1850 NJ
preplace netloc processing_system7_0_axi_periph_M16_AXI 1 7 2 NJ 1820 3070
preplace netloc Timer_10us_m_0_timer_10us_o 1 5 1 NJ
preplace netloc processing_system7_0_axi_periph_M06_AXI 1 7 1 2620
preplace netloc processing_system7_0_DDR 1 6 4 NJ 2390 NJ 2390 NJ 2360 NJ
preplace netloc axi_gpio_17_gpio_io_o 1 1 8 360 690 NJ 690 NJ 690 NJ 690 NJ 690 NJ 690 NJ 690 3080
preplace netloc axi_gpio_19_gpio_io_o 1 1 8 370 830 NJ 830 NJ 830 NJ 830 NJ 830 NJ 830 NJ 830 3080
preplace netloc clk_n_1 1 0 1 NJ
preplace netloc axi_gpio_10_gpio_io_o 1 1 8 370 2190 NJ 2190 NJ 2190 NJ 2190 NJ 2190 NJ 2420 NJ 2320 2990
preplace netloc Vaux3_1 1 0 8 NJ 2760 NJ 2760 NJ 2760 NJ 2760 NJ 2760 NJ 2760 NJ 2760 NJ
preplace netloc axi_gpio_16_gpio_io_o 1 1 8 290 2210 NJ 2210 NJ 2210 NJ 2210 NJ 2210 NJ 2370 NJ 2370 3000
preplace netloc processing_system7_0_axi_periph_M05_AXI 1 7 1 2560
preplace netloc processing_system7_0_axi_periph_M20_AXI 1 7 1 2610
preplace netloc processing_system7_0_axi_periph_M21_AXI 1 7 1 2590
preplace netloc processing_system7_0_FCLK_RESET0_N 1 1 6 380 1510 NJ 1510 NJ 1510 NJ 1510 NJ 1510 2120
preplace netloc axi_gpio_15_gpio_io_o 1 9 1 NJ
preplace netloc processing_system7_0_axi_periph_M10_AXI 1 7 1 2560
preplace netloc processing_system7_0_axi_periph_M02_AXI 1 7 1 2580
preplace netloc processing_system7_0_axi_periph_M03_AXI 1 7 1 2540
preplace netloc axi_uartlite_0_UART 1 9 1 NJ
preplace netloc processing_system7_0_axi_periph_M07_AXI 1 7 1 2640
preplace netloc DataGen_3ch_0_hf_ch_send_flag 1 2 7 700 1160 NJ 1110 NJ 1110 NJ 1110 NJ 1110 NJ 1110 3080
preplace netloc processing_system7_0_axi_periph_M09_AXI 1 7 1 2620
preplace netloc processing_system7_0_axi_periph_M11_AXI 1 7 1 2680
preplace netloc processing_system7_0_axi_periph_M13_AXI 1 7 1 2720
preplace netloc axi_dma_0_M_AXI_S2MM 1 4 1 1410
preplace netloc processing_system7_0_axi_periph_M19_AXI 1 7 1 2550
preplace netloc processing_system7_0_axi_periph_M22_AXI 1 7 1 2670
preplace netloc processing_system7_0_axi_periph_M01_AXI 1 7 1 2570
preplace netloc processing_system7_0_axi_periph_M12_AXI 1 7 2 NJ 1670 3030
preplace netloc axis_data_fifo_0_M_AXIS 1 3 1 N
preplace netloc processing_system7_0_FCLK_CLK0 1 1 8 320 980 730 1140 1080 1150 1430 1160 1740 1160 2140 1120 2650 1530 3050
preplace netloc rst_processing_system7_0_100M_interconnect_aresetn 1 2 5 750 1350 NJ 1350 1400 1180 NJ 1180 2240
preplace netloc processing_system7_0_axi_periph_M00_AXI 1 3 5 1090 710 NJ 710 NJ 710 NJ 710 2530
preplace netloc axi_gpio_7_gpio_io_o 1 1 8 340 2150 NJ 2150 NJ 2150 NJ 2150 NJ 2150 NJ 2330 NJ 2160 2980
preplace netloc axi_gpio_5_gpio_io_o 1 1 8 310 940 NJ 940 NJ 940 NJ 940 NJ 940 NJ 940 NJ 1390 3080
preplace netloc hf_ch3_1 1 0 2 NJ 1090 NJ
preplace netloc axi_gpio_21_gpio_io_o 1 1 8 260 2220 NJ 2220 NJ 2220 NJ 2220 NJ 2220 NJ 2380 NJ 2380 2980
preplace netloc processing_system7_0_axi_periph_M14_AXI 1 7 1 2540
preplace netloc axi_gpio_4_gpio_io_o 1 1 8 280 410 NJ 410 NJ 410 NJ 410 NJ 410 NJ 410 NJ 410 3080
preplace netloc DataGen_3ch_0_S_AXIS_aresetn 1 2 1 710
preplace netloc clk_wiz_0_clk_out1 1 1 4 230 950 NJ 950 NJ 950 NJ
preplace netloc clk_p_1 1 0 1 NJ
preplace netloc axi_gpio_11_gpio_io_o 1 9 1 NJ
preplace netloc processing_system7_0_M_AXI_GP0 1 6 1 2150
preplace netloc DataGen_3ch_0_S_AXIS_aclk 1 2 1 720
preplace netloc axi_mem_intercon_M00_AXI 1 5 1 1730
preplace netloc axi_gpio_8_gpio_io_o 1 1 8 310 2180 NJ 2180 NJ 2180 NJ 2180 NJ 2180 NJ 2410 NJ 2330 2980
preplace netloc axi_dma_0_s2mm_introut 1 4 2 1440 1190 NJ
preplace netloc processing_system7_0_axi_periph_M23_AXI 1 7 1 2690
preplace netloc processing_system7_0_axi_periph_M04_AXI 1 7 1 2550
preplace netloc rst_processing_system7_0_100M_peripheral_aresetn 1 2 7 740 1340 1080 1330 1420 1170 NJ 1170 2250 1130 2660 1840 3090
preplace netloc axi_gpio_2_gpio_io_o 1 1 8 350 550 NJ 550 NJ 550 NJ 550 NJ 550 NJ 550 NJ 550 3090
preplace netloc processing_system7_0_axi_periph_M15_AXI 1 7 2 NJ 1810 3060
preplace netloc axi_gpio_12_gpio_io_o 1 1 8 350 2200 NJ 2200 NJ 2200 NJ 2200 NJ 2200 NJ 2360 NJ 2360 3010
levelinfo -pg 1 -10 120 540 920 1240 1580 1930 2390 2850 3220 3370 -top 0 -bot 2860
",
}

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


