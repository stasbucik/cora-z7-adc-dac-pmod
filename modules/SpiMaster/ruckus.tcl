loadSource -dir "$::DIR_PATH/rtl" -fileType "vhdl 2008"
loadSource -sim_only -dir "$::DIR_PATH/tb" -fileType "vhdl 2008"
loadIps "$::DIR_PATH/ip"
