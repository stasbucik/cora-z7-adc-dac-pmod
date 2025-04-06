set ipName fifo_sync_data
create_ip -name fifo_generator -vendor xilinx.com -library ip -version 13.2 -module_name ${ipName}
set_property -dict [list \
  CONFIG.Clock_Type_AXI {Independent_Clock} \
  CONFIG.INTERFACE_TYPE {AXI_STREAM} \
  CONFIG.Input_Depth_axis {16} \
  CONFIG.TDATA_NUM_BYTES {2} \
  CONFIG.TDEST_WIDTH {4} \
  CONFIG.TID_WIDTH {4} \
] [get_ips ${ipName}]
generate_target {instantiation_template} [get_files $::env(OUT_DIR)/$::env(VIVADO_PROJECT).srcs/[get_filesets sources_1]/ip/${ipName}/${ipName}.xci]