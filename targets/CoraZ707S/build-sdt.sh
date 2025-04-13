#!/usr/bin/env sh

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

