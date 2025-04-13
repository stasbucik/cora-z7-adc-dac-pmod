set customdtsi [lindex $argv 2]
set outdir [lindex $argv 1]
set xsa [lindex $argv 0]
exec rm -rf $outdir
sdtgen set_dt_param -xsa $xsa -dir $outdir -board_dts coraz7 -include_dts $customdtsi
sdtgen generate_sdt
