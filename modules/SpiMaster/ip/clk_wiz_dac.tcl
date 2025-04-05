set ipName clk_wiz_dac
create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name ${ipName}
set_property -dict [list \
  CONFIG.CLKOUT1_DRIVES {BUFG} \
  CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {100} \
  CONFIG.PRIMITIVE {PLL} \
  CONFIG.PRIM_IN_FREQ {125} \
  CONFIG.RESET_PORT {reset} \
  CONFIG.RESET_TYPE {ACTIVE_HIGH} \
  CONFIG.CLKOUT1_JITTER {237.312} \
  CONFIG.CLKOUT1_PHASE_ERROR {249.865} \
  CONFIG.MMCM_CLKFBOUT_MULT_F {36} \
  CONFIG.MMCM_CLKOUT0_DIVIDE_F {9} \
] [get_ips ${ipName}]
generate_target {instantiation_template} [get_files $::env(OUT_DIR)/$::env(VIVADO_PROJECT).srcs/[get_filesets sources_1]/ip/${ipName}/${ipName}.xci]