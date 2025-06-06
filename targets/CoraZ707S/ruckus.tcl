source $::env(RUCKUS_DIR)/vivado_proc.tcl
source $::DIR_PATH/scripts/utils.tcl

loadSource -dir "$::DIR_PATH/rtl" -fileType "vhdl 2008"
loadConstraints -dir "$::DIR_PATH/rtl"

setBoardRepo "$::DIR_PATH/board_files"
setBoardPart "digilentinc.com:cora-z7-07s:part0:1.1"

loadRuckusTcl $::env(TOP_DIR)/modules/Common
loadRuckusTcl $::env(TOP_DIR)/modules/Axi4
loadRuckusTcl $::env(TOP_DIR)/modules/SpiMaster
loadRuckusTcl $::env(TOP_DIR)/modules/DataBuffer
loadRuckusTcl $::env(TOP_DIR)/modules/DacAD5451
loadRuckusTcl $::env(TOP_DIR)/modules/AdcMAX11105
loadRuckusTcl $::env(TOP_DIR)/modules/DataGenerator
loadRuckusTcl $::env(TOP_DIR)/modules/Infrastructure
loadRuckusTcl $::env(TOP_DIR)/modules/Registers
