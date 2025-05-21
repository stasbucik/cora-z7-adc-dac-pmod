set ipName clk_wiz_mmc_100_64
create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name ${ipName}
set_property -dict [list \
  CONFIG.CLKOUT1_DRIVES {BUFGCE} \
  CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {64} \
  CONFIG.FEEDBACK_SOURCE {FDBK_AUTO} \
  CONFIG.MMCM_CLKOUT0_DIVIDE_F {15.625} \
  CONFIG.PRIM_SOURCE {Global_buffer} \
  CONFIG.USE_SAFE_CLOCK_STARTUP {true} \
  CONFIG.AXI_DRP {false} \
  CONFIG.PHASE_DUTY_CONFIG {false} \
  CONFIG.USE_DYN_RECONFIG {true} \
] [get_ips ${ipName}]
generate_target {instantiation_template} [get_files $::env(OUT_DIR)/$::env(VIVADO_PROJECT).srcs/[get_filesets sources_1]/ip/${ipName}/${ipName}.xci]
