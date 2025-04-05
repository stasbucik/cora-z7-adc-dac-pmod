source $::env(RUCKUS_DIR)/vivado_proc.tcl
source $::DIR_PATH/scripts.tcl

loadSource -dir "$::DIR_PATH/rtl" -fileType "vhdl 2008"
loadConstraints -dir "$::DIR_PATH/rtl"

setBoardRepo "$::DIR_PATH/board_files"
setBoardPart "digilentinc.com:cora-z7-07s:part0:1.1"
setIpRepo "$::env(TOP_DIR)/submodules"

loadRuckusTcl $::env(TOP_DIR)/modules/Axi4
loadRuckusTcl $::env(TOP_DIR)/modules/SpiMaster
loadRuckusTcl $::env(TOP_DIR)/modules/DataGenerator
loadRuckusTcl $::env(TOP_DIR)/modules/Infrastructure
