proc setBoardRepo path {
	set_param board.repoPaths ${path}
	set_property BOARD_PART_REPO_PATHS ${path} [current_project]
	puts "Set Board Part RepoPath: [get_param board.repoPaths]"
}

proc setBoardPart part {
	set_property board_part ${part} [current_project]
}

proc setIpRepo path {
	if {[string equal [get_filesets -quiet sources_1] ""]} {
	    puts "INFO: Creating sources_1 fileset"
	    create_fileset -srcset sources_1
	}
	puts "INFO: Setting IP repository paths"
	set obj [get_filesets sources_1]
	set_property "ip_repo_paths" "[file normalize ${path}]" $obj
	puts "INFO: Refreshing IP repositories"
	update_ip_catalog -rebuild
	foreach ip [get_ips -filter "IS_LOCKED==1"] {
	    upgrade_ip -vlnv [get_property UPGRADE_VERSIONS $ip] $ip
	    export_ip_user_files -of_objects $ip -no_script -sync -force -quiet
	}
}

proc loadBlockDesign file {
	package require fileutil
	set strip [file rootname [file tail ${file}]]
	set bdPath [fileutil::findByPattern $::env(OUT_DIR) ${strip}.bd]
	if { ${bdPath} eq "" } {
		puts "INFO: Building block design : ${file}"
		source ${file}
		set strip [file rootname [file tail ${file}]]
		set bdPath [fileutil::findByPattern $::env(OUT_DIR) ${strip}.bd]
		make_wrapper -files [get_files ${bdPath}] -top
		set wrapperPath [fileutil::findByPattern $::env(OUT_DIR) ${strip}_wrapper.vhd]
		add_files -norecurse ${wrapperPath}
		set_property synth_checkpoint_mode Singular [get_files ${bdPath}]
	} else {
		puts "INFO: Block design exists: ${bdPath}"
		puts "INFO: Skipping..."
	}
}

proc loadIps path {
	set list ""
	set list_rc [catch {
		set list [glob -directory ${path} *.tcl]
	} _RESULT]
	if { ${list} != "" } {
		foreach file ${list} {
			set filename [file tail ${file}]
			puts "INFO: Found IP .tcl: ${filename}"
			set strip [file rootname ${filename}]
			if { [get_ips ${strip}] eq ""  } {
				source ${file}
			}
		}
	}
}