source -quiet $::env(RUCKUS_DIR)/vivado/env_var.tcl
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

open_run synth_1

set enable 0
if { ${enable} == 1 } {
	set ilaName "u_ila_ps_clk_domain"
	set ilaSize 2048
	set ilaClk "clk"

	CreateDebugCore ${ilaName}
	set_property C_DATA_DEPTH ${ilaSize} [get_debug_cores ${ilaName}]
	SetDebugCoreClk ${ilaName} ${ilaClk}

	ConfigProbe ${ilaName} {dacSdin}
	ConfigProbe ${ilaName} {dacSync}
	ConfigProbe ${ilaName} {dacHighz}

	ConfigProbe ${ilaName} {axisDacWriteSrc[TDEST]}
	ConfigProbe ${ilaName} {axisDacWriteSrc[TID]}
	ConfigProbe ${ilaName} {axisDacWriteSrc[TLAST]}
	ConfigProbe ${ilaName} {axisDacWriteSrc[TUSER]}
	ConfigProbe ${ilaName} {axisDacWriteSrc[TVALID]}
	ConfigProbe ${ilaName} {axisDacWriteSrc[TWAKEUP]}
	ConfigProbe ${ilaName} {axisDacWriteSrc[TDATA][*]}
	ConfigProbe ${ilaName} {axisDacWriteSrc[TKEEP][*]}
	ConfigProbe ${ilaName} {axisDacWriteSrc[TSTRB][*]}

	ConfigProbe ${ilaName} {axisDacWriteDst[TREADY]}

	ConfigProbe ${ilaName} {axisAdcReadSrc[TDEST]}
	ConfigProbe ${ilaName} {axisAdcReadSrc[TID]}
	ConfigProbe ${ilaName} {axisAdcReadSrc[TLAST]}
	ConfigProbe ${ilaName} {axisAdcReadSrc[TUSER]}
	ConfigProbe ${ilaName} {axisAdcReadSrc[TVALID]}
	ConfigProbe ${ilaName} {axisAdcReadSrc[TWAKEUP]}
	ConfigProbe ${ilaName} {axisAdcReadSrc[TDATA][*]}
	ConfigProbe ${ilaName} {axisAdcReadSrc[TKEEP][*]}
	ConfigProbe ${ilaName} {axisAdcReadSrc[TSTRB][*]}

	ConfigProbe ${ilaName} {axisAdcReadDst[TREADY]}

	ConfigProbe ${ilaName} {adcOverflow}

	WriteDebugProbes ${ilaName} ${PROJ_DIR}/images/debug_probes.ltx
}

set enable 0
if { ${enable} == 1 } {
	set ilaName "u_ila_ps_adc_clk_domain"
	set ilaSize 2048
	set ilaClk "adcSpiClk"

	CreateDebugCore ${ilaName}
	set_property C_DATA_DEPTH ${ilaSize} [get_debug_cores ${ilaName}]
	SetDebugCoreClk ${ilaName} ${ilaClk}

	ConfigProbe ${ilaName} {adcDout}
	ConfigProbe ${ilaName} {adcCs}

	WriteDebugProbes ${ilaName} ${PROJ_DIR}/images/debug_probes.ltx
}