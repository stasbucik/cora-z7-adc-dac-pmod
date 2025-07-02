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

# version 0.0.1.0
export PRJ_VERSION = 0x000000100

export GIT_BYPASS = 1
export REMOVE_UNUSED_CODE = 0
export GEN_XSA_IMAGE = 1

export TOP_DIR = $(abspath $(PWD)/../..)

target : prom

export PRJ_PART = xc7z007sclg400-1

include ../../submodules/ruckus/system_vivado.mk

.PHONY : sdt
sdt : target
	$(PROJ_DIR)/build-sdt.sh

clean-sdt :
	rm -rf $(PROJ_DIR)/sdt
