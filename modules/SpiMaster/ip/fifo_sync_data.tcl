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

set ipName fifo_sync_data
create_ip -name fifo_generator -vendor xilinx.com -library ip -version 13.2 -module_name ${ipName}
set_property -dict [list \
  CONFIG.Clock_Type_AXI {Independent_Clock} \
  CONFIG.FIFO_Implementation_axis {Independent_Clocks_Distributed_RAM} \
  CONFIG.INTERFACE_TYPE {AXI_STREAM} \
  CONFIG.Input_Depth_axis {16} \
  CONFIG.TDATA_NUM_BYTES {2} \
  CONFIG.TDEST_WIDTH {0} \
  CONFIG.TID_WIDTH {0} \
  CONFIG.TUSER_WIDTH {0} \
] [get_ips ${ipName}]
generate_target {instantiation_template} [get_files $::env(OUT_DIR)/$::env(VIVADO_PROJECT).srcs/[get_filesets sources_1]/ip/${ipName}/${ipName}.xci]