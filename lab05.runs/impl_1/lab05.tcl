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
set ACTIVE_STEP init_design
set rc [catch {
  create_msg_db init_design.pb
  set_param xicom.use_bs_reader 1
  create_project -in_memory -part xc7z020clg484-1
  set_property board_part em.avnet.com:zed:part0:1.3 [current_project]
  set_property design_mode GateLvl [current_fileset]
  set_param project.singleFileAddWarning.threshold 0
  set_property webtalk.parent_dir C:/Users/user/Documents/.git/space_race/lab05.cache/wt [current_project]
  set_property parent.project_path C:/Users/user/Documents/.git/space_race/lab05.xpr [current_project]
  set_property ip_output_repo C:/Users/user/Documents/.git/space_race/lab05.cache/ip [current_project]
  set_property ip_cache_permissions {read write} [current_project]
  add_files -quiet C:/Users/user/Documents/.git/space_race/lab05.runs/synth_1/lab05.dcp
  read_xdc C:/Users/user/Documents/.git/space_race/lab05.srcs/constrs_1/new/lab05.xdc
  link_design -top lab05 -part xc7z020clg484-1
  write_hwdef -file lab05.hwdef
  close_msg_db -file init_design.pb
} RESULT]
if {$rc} {
  step_failed init_design
  return -code error $RESULT
} else {
  end_step init_design
  unset ACTIVE_STEP 
}

start_step opt_design
set ACTIVE_STEP opt_design
set rc [catch {
  create_msg_db opt_design.pb
  opt_design 
  write_checkpoint -force lab05_opt.dcp
  report_drc -file lab05_drc_opted.rpt
  close_msg_db -file opt_design.pb
} RESULT]
if {$rc} {
  step_failed opt_design
  return -code error $RESULT
} else {
  end_step opt_design
  unset ACTIVE_STEP 
}

start_step place_design
set ACTIVE_STEP place_design
set rc [catch {
  create_msg_db place_design.pb
  implement_debug_core 
  place_design 
  write_checkpoint -force lab05_placed.dcp
  report_io -file lab05_io_placed.rpt
  report_utilization -file lab05_utilization_placed.rpt -pb lab05_utilization_placed.pb
  report_control_sets -verbose -file lab05_control_sets_placed.rpt
  close_msg_db -file place_design.pb
} RESULT]
if {$rc} {
  step_failed place_design
  return -code error $RESULT
} else {
  end_step place_design
  unset ACTIVE_STEP 
}

start_step route_design
set ACTIVE_STEP route_design
set rc [catch {
  create_msg_db route_design.pb
  route_design 
  write_checkpoint -force lab05_routed.dcp
  report_drc -file lab05_drc_routed.rpt -pb lab05_drc_routed.pb -rpx lab05_drc_routed.rpx
  report_methodology -file lab05_methodology_drc_routed.rpt -rpx lab05_methodology_drc_routed.rpx
  report_timing_summary -warn_on_violation -max_paths 10 -file lab05_timing_summary_routed.rpt -rpx lab05_timing_summary_routed.rpx
  report_power -file lab05_power_routed.rpt -pb lab05_power_summary_routed.pb -rpx lab05_power_routed.rpx
  report_route_status -file lab05_route_status.rpt -pb lab05_route_status.pb
  report_clock_utilization -file lab05_clock_utilization_routed.rpt
  close_msg_db -file route_design.pb
} RESULT]
if {$rc} {
  write_checkpoint -force lab05_routed_error.dcp
  step_failed route_design
  return -code error $RESULT
} else {
  end_step route_design
  unset ACTIVE_STEP 
}

start_step write_bitstream
set ACTIVE_STEP write_bitstream
set rc [catch {
  create_msg_db write_bitstream.pb
  catch { write_mem_info -force lab05.mmi }
  write_bitstream -force -no_partial_bitfile lab05.bit 
  catch { write_sysdef -hwdef lab05.hwdef -bitfile lab05.bit -meminfo lab05.mmi -file lab05.sysdef }
  catch {write_debug_probes -quiet -force debug_nets}
  close_msg_db -file write_bitstream.pb
} RESULT]
if {$rc} {
  step_failed write_bitstream
  return -code error $RESULT
} else {
  end_step write_bitstream
  unset ACTIVE_STEP 
}

