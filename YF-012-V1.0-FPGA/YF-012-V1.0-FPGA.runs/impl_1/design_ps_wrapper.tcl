proc start_step { step } {
  set stopFile ".stop.rst"
  if {[file isfile .stop.rst]} {
    puts ""
    puts "*** Halting run - EA reset detected ***"
    puts ""
    puts ""
    return -code error
  }
  set beginFile ".$step.begin.rst"
  set platform "$::tcl_platform(platform)"
  set user "$::tcl_platform(user)"
  set pid [pid]
  set host ""
  if { [string equal $platform unix] } {
    if { [info exist ::env(HOSTNAME)] } {
      set host $::env(HOSTNAME)
    }
  } else {
    if { [info exist ::env(COMPUTERNAME)] } {
      set host $::env(COMPUTERNAME)
    }
  }
  set ch [open $beginFile w]
  puts $ch "<?xml version=\"1.0\"?>"
  puts $ch "<ProcessHandle Version=\"1\" Minor=\"0\">"
  puts $ch "    <Process Command=\".planAhead.\" Owner=\"$user\" Host=\"$host\" Pid=\"$pid\">"
  puts $ch "    </Process>"
  puts $ch "</ProcessHandle>"
  close $ch
}

proc end_step { step } {
  set endFile ".$step.end.rst"
  set ch [open $endFile w]
  close $ch
}

proc step_failed { step } {
  set endFile ".$step.error.rst"
  set ch [open $endFile w]
  close $ch
}

set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000

start_step init_design
set rc [catch {
  create_msg_db init_design.pb
  open_checkpoint F:/Project/RG-2018-YF-001/FPGA/YF-012-V2.2-FPGA/YF-012-V1.0-FPGA/YF-012-V1.0-FPGA.runs/impl_1/design_ps_wrapper.dcp
  set_property webtalk.parent_dir F:/Project/RG-2018-YF-001/FPGA/YF-012-V2.2-FPGA/YF-012-V1.0-FPGA/YF-012-V1.0-FPGA.cache/wt [current_project]
  set_property parent.project_path F:/Project/RG-2018-YF-001/FPGA/YF-012-V2.2-FPGA/YF-012-V1.0-FPGA/YF-012-V1.0-FPGA.xpr [current_project]
  set_property ip_repo_paths {
  f:/Project/RG-2018-YF-001/FPGA/YF-012-V2.2-FPGA/YF-012-V1.0-FPGA/YF-012-V1.0-FPGA.cache/ip
  F:/Project/RG-2018-YF-001/FPGA/YF-012-V2.2-FPGA/YF-012-V1.0-FPGA/Miz_ip_lib
} [current_project]
  set_property ip_output_repo f:/Project/RG-2018-YF-001/FPGA/YF-012-V2.2-FPGA/YF-012-V1.0-FPGA/YF-012-V1.0-FPGA.cache/ip [current_project]
  close_msg_db -file init_design.pb
} RESULT]
if {$rc} {
  step_failed init_design
  return -code error $RESULT
} else {
  end_step init_design
}

start_step opt_design
set rc [catch {
  create_msg_db opt_design.pb
  catch {write_debug_probes -quiet -force debug_nets}
  opt_design 
  write_checkpoint -force design_ps_wrapper_opt.dcp
  report_drc -file design_ps_wrapper_drc_opted.rpt
  close_msg_db -file opt_design.pb
} RESULT]
if {$rc} {
  step_failed opt_design
  return -code error $RESULT
} else {
  end_step opt_design
}

start_step place_design
set rc [catch {
  create_msg_db place_design.pb
  catch {write_hwdef -file design_ps_wrapper.hwdef}
  place_design 
  write_checkpoint -force design_ps_wrapper_placed.dcp
  report_io -file design_ps_wrapper_io_placed.rpt
  report_utilization -file design_ps_wrapper_utilization_placed.rpt -pb design_ps_wrapper_utilization_placed.pb
  report_control_sets -verbose -file design_ps_wrapper_control_sets_placed.rpt
  close_msg_db -file place_design.pb
} RESULT]
if {$rc} {
  step_failed place_design
  return -code error $RESULT
} else {
  end_step place_design
}

start_step route_design
set rc [catch {
  create_msg_db route_design.pb
  route_design 
  write_checkpoint -force design_ps_wrapper_routed.dcp
  report_drc -file design_ps_wrapper_drc_routed.rpt -pb design_ps_wrapper_drc_routed.pb
  report_timing_summary -warn_on_violation -max_paths 10 -file design_ps_wrapper_timing_summary_routed.rpt -rpx design_ps_wrapper_timing_summary_routed.rpx
  report_power -file design_ps_wrapper_power_routed.rpt -pb design_ps_wrapper_power_summary_routed.pb
  report_route_status -file design_ps_wrapper_route_status.rpt -pb design_ps_wrapper_route_status.pb
  report_clock_utilization -file design_ps_wrapper_clock_utilization_routed.rpt
  close_msg_db -file route_design.pb
} RESULT]
if {$rc} {
  step_failed route_design
  return -code error $RESULT
} else {
  end_step route_design
}

start_step write_bitstream
set rc [catch {
  create_msg_db write_bitstream.pb
  catch { write_mem_info -force design_ps_wrapper.mmi }
  write_bitstream -force design_ps_wrapper.bit 
  catch { write_sysdef -hwdef design_ps_wrapper.hwdef -bitfile design_ps_wrapper.bit -meminfo design_ps_wrapper.mmi -file design_ps_wrapper.sysdef }
  close_msg_db -file write_bitstream.pb
} RESULT]
if {$rc} {
  step_failed write_bitstream
  return -code error $RESULT
} else {
  end_step write_bitstream
}

