source $::env(RUCKUS_DIR)/vivado_proc.tcl

loadSource -dir "$::DIR_PATH/rtl" -fileType "vhdl 2008"
loadConstraints -dir "$::DIR_PATH/rtl"

set_param board.repoPaths "$::DIR_PATH/board_files"
set_property BOARD_PART_REPO_PATHS "$::DIR_PATH/board_files" [current_project]
puts "Set Board Part RepoPath: [get_param board.repoPaths]"
set_property board_part "digilentinc.com:cora-z7-07s:part0:1.1" [current_project]

if {[string equal [get_filesets -quiet sources_1] ""]} {
    puts "INFO: Creating sources_1 fileset"
    create_fileset -srcset sources_1
}
puts "INFO: Setting IP repository paths"
set obj [get_filesets sources_1]
set_property "ip_repo_paths" "[file normalize $::env(TOP_DIR)/submodules]" $obj
puts "INFO: Refreshing IP repositories"
update_ip_catalog -rebuild
foreach ip [get_ips -filter "IS_LOCKED==1"] {
    upgrade_ip -vlnv [get_property UPGRADE_VERSIONS $ip] $ip
    export_ip_user_files -of_objects $ip -no_script -sync -force -quiet
}

loadRuckusTcl $::env(TOP_DIR)/modules/SpiMasterAdapter
loadRuckusTcl $::env(TOP_DIR)/modules/DataGenerator
loadRuckusTcl $::env(TOP_DIR)/modules/Infrastructure
