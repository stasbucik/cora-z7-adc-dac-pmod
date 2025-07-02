#  Copyright 2025, University of Ljubljana
#
#  This file is part of cora-z7-adc-dac-pmod.
#  cora-z7-adc-dac-pmod is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by the Free Software Foundation,
#  either version 3 of the License, or any later version.
#  cora-z7-adc-dac-pmod is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
#  FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#  You should have received a copy of the GNU General Public License along with cora-z7-adc-dac-pmod.
#  If not, see <https://www.gnu.org/licenses/>.

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
