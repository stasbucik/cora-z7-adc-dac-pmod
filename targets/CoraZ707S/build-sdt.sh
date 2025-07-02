#!/usr/bin/env sh

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

PROJ_DIR=${PROJ_DIR:-$(readlink -f $(pwd))}
TOP_DIR=${TOP_DIR:-$(readlink -f $(pwd)/../..)}

export CUSTOM_SDT_REPO=$TOP_DIR/submodules/system-device-tree-xlnx

latest_file=$(ls -t $PROJ_DIR/images/*.xsa 2>/dev/null | head -n 1)
if [ -n "$latest_file" ]; then
    echo "Latest .xsa file: $latest_file"
    /opt/Xilinx/Vivado/2024.2/xsct-trim/bin/xsct $PROJ_DIR/scripts/sdt.tcl $latest_file $PROJ_DIR/sdt $PROJ_DIR/device-tree/custom_pl.dtsi
else
    echo "No .xsa files found in $PROJ_DIR/images/"
fi

