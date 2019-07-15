# 
# Report generation script generated by Vivado
# 

proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
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


start_step init_design
set ACTIVE_STEP init_design
set rc [catch {
  create_msg_db init_design.pb
  set_param chipscope.maxJobs 1
  create_project -in_memory -part xc7a15tftg256-1
  set_property design_mode GateLvl [current_fileset]
  set_param project.singleFileAddWarning.threshold 0
  set_property webtalk.parent_dir D:/Hongjie/hongjie/V1/OSC1LITE-master_new_/OSC1LITE-master_newnew/OSC1LITE-master/project_LITE/project_LITE/17.cache/wt [current_project]
  set_property parent.project_path D:/Hongjie/hongjie/V1/OSC1LITE-master_new_/OSC1LITE-master_newnew/OSC1LITE-master/project_LITE/project_LITE/17.xpr [current_project]
  set_property ip_output_repo D:/Hongjie/hongjie/V1/OSC1LITE-master_new_/OSC1LITE-master_newnew/OSC1LITE-master/project_LITE/project_LITE/17.cache/ip [current_project]
  set_property ip_cache_permissions {read write} [current_project]
  set_property XPM_LIBRARIES XPM_MEMORY [current_project]
  add_files -quiet D:/Hongjie/hongjie/V1/OSC1LITE-master_new_/OSC1LITE-master_newnew/OSC1LITE-master/project_LITE/project_LITE/17.runs/synth_1/OSC1_LITE_Control.dcp
  read_ip -quiet D:/Hongjie/hongjie/V1/OSC1LITE-master_new_/OSC1LITE-master_newnew/OSC1LITE-master/project_LITE/project_LITE/17.srcs/sources_1/ip/blk_mem_gen_0/blk_mem_gen_0.xci
  read_xdc D:/Hongjie/hongjie/V1/OSC1LITE-master_new_/OSC1LITE-master_newnew/OSC1LITE-master/project_LITE/project_LITE/17.srcs/constrs_1/imports/Desktop/xem7001.xdc
  link_design -top OSC1_LITE_Control -part xc7a15tftg256-1
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
  write_checkpoint -force OSC1_LITE_Control_opt.dcp
  create_report "impl_1_opt_report_drc_0" "report_drc -file OSC1_LITE_Control_drc_opted.rpt -pb OSC1_LITE_Control_drc_opted.pb -rpx OSC1_LITE_Control_drc_opted.rpx"
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
  if { [llength [get_debug_cores -quiet] ] > 0 }  { 
    implement_debug_core 
  } 
  place_design 
  write_checkpoint -force OSC1_LITE_Control_placed.dcp
  create_report "impl_1_place_report_io_0" "report_io -file OSC1_LITE_Control_io_placed.rpt"
  create_report "impl_1_place_report_utilization_0" "report_utilization -file OSC1_LITE_Control_utilization_placed.rpt -pb OSC1_LITE_Control_utilization_placed.pb"
  create_report "impl_1_place_report_control_sets_0" "report_control_sets -verbose -file OSC1_LITE_Control_control_sets_placed.rpt"
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
  write_checkpoint -force OSC1_LITE_Control_routed.dcp
  create_report "impl_1_route_report_drc_0" "report_drc -file OSC1_LITE_Control_drc_routed.rpt -pb OSC1_LITE_Control_drc_routed.pb -rpx OSC1_LITE_Control_drc_routed.rpx"
  create_report "impl_1_route_report_methodology_0" "report_methodology -file OSC1_LITE_Control_methodology_drc_routed.rpt -pb OSC1_LITE_Control_methodology_drc_routed.pb -rpx OSC1_LITE_Control_methodology_drc_routed.rpx"
  create_report "impl_1_route_report_power_0" "report_power -file OSC1_LITE_Control_power_routed.rpt -pb OSC1_LITE_Control_power_summary_routed.pb -rpx OSC1_LITE_Control_power_routed.rpx"
  create_report "impl_1_route_report_route_status_0" "report_route_status -file OSC1_LITE_Control_route_status.rpt -pb OSC1_LITE_Control_route_status.pb"
  create_report "impl_1_route_report_timing_summary_0" "report_timing_summary -max_paths 10 -file OSC1_LITE_Control_timing_summary_routed.rpt -pb OSC1_LITE_Control_timing_summary_routed.pb -rpx OSC1_LITE_Control_timing_summary_routed.rpx -warn_on_violation "
  create_report "impl_1_route_report_incremental_reuse_0" "report_incremental_reuse -file OSC1_LITE_Control_incremental_reuse_routed.rpt"
  create_report "impl_1_route_report_clock_utilization_0" "report_clock_utilization -file OSC1_LITE_Control_clock_utilization_routed.rpt"
  create_report "impl_1_route_report_bus_skew_0" "report_bus_skew -warn_on_violation -file OSC1_LITE_Control_bus_skew_routed.rpt -pb OSC1_LITE_Control_bus_skew_routed.pb -rpx OSC1_LITE_Control_bus_skew_routed.rpx"
  close_msg_db -file route_design.pb
} RESULT]
if {$rc} {
  write_checkpoint -force OSC1_LITE_Control_routed_error.dcp
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
  set_property XPM_LIBRARIES XPM_MEMORY [current_project]
  catch { write_mem_info -force OSC1_LITE_Control.mmi }
  write_bitstream -force OSC1_LITE_Control.bit 
  catch {write_debug_probes -quiet -force OSC1_LITE_Control}
  catch {file copy -force OSC1_LITE_Control.ltx debug_nets.ltx}
  close_msg_db -file write_bitstream.pb
} RESULT]
if {$rc} {
  step_failed write_bitstream
  return -code error $RESULT
} else {
  end_step write_bitstream
  unset ACTIVE_STEP 
}
