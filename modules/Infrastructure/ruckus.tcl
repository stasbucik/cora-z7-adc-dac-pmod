source "$::DIR_PATH/bd/Infrastructure.tcl"
package require fileutil
set bdPath [fileutil::findByPattern $::env(OUT_DIR) Infrastructure.bd]
puts "INFO: Found block design path: ${bdPath}"
make_wrapper -files [get_files ${bdPath}] -top
set wrapperPath [fileutil::findByPattern $::env(OUT_DIR) Infrastructure_wrapper.vhd]
add_files -norecurse ${wrapperPath}
set_property synth_checkpoint_mode Singular [get_files ${bdPath}]
