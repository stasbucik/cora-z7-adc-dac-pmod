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
	

	ConfigProbe ${ilaName} {axiPsSrc[rd][ARID]}
	ConfigProbe ${ilaName} {axiPsSrc[rd][ARADDR][*]}
	ConfigProbe ${ilaName} {axiPsSrc[rd][ARLEN][*]}
	ConfigProbe ${ilaName} {axiPsSrc[rd][ARSIZE][*]}
	ConfigProbe ${ilaName} {axiPsSrc[rd][ARBURST][*]}
	ConfigProbe ${ilaName} {axiPsSrc[rd][ARLOCK]}
	ConfigProbe ${ilaName} {axiPsSrc[rd][ARCACHE][*]}
	ConfigProbe ${ilaName} {axiPsSrc[rd][ARPROT][*]}
	ConfigProbe ${ilaName} {axiPsSrc[rd][ARQOS][*]}
	ConfigProbe ${ilaName} {axiPsSrc[rd][ARREGION][*]}
	ConfigProbe ${ilaName} {axiPsSrc[rd][ARUSER]}
	ConfigProbe ${ilaName} {axiPsSrc[rd][ARVALID]}
	ConfigProbe ${ilaName} {axiPsSrc[rd][RREADY]}

	ConfigProbe ${ilaName} {axiPsDst[rd][ARREADY]}
	ConfigProbe ${ilaName} {axiPsDst[rd][RID]}
	ConfigProbe ${ilaName} {axiPsDst[rd][RDATA][*]}
	ConfigProbe ${ilaName} {axiPsDst[rd][RRESP][*]}
	ConfigProbe ${ilaName} {axiPsDst[rd][RLAST]}
	ConfigProbe ${ilaName} {axiPsDst[rd][RUSER]}
	ConfigProbe ${ilaName} {axiPsDst[rd][RVALID]}

	ConfigProbe ${ilaName} {axiPsSrc[wr][AWID]}
	ConfigProbe ${ilaName} {axiPsSrc[wr][AWADDR][*]}
	ConfigProbe ${ilaName} {axiPsSrc[wr][AWLEN][*]}
	ConfigProbe ${ilaName} {axiPsSrc[wr][AWSIZE][*]}
	ConfigProbe ${ilaName} {axiPsSrc[wr][AWBURST][*]}
	ConfigProbe ${ilaName} {axiPsSrc[wr][AWLOCK]}
	ConfigProbe ${ilaName} {axiPsSrc[wr][AWCACHE][*]}
	ConfigProbe ${ilaName} {axiPsSrc[wr][AWPROT][*]}
	ConfigProbe ${ilaName} {axiPsSrc[wr][AWQOS][*]}
	ConfigProbe ${ilaName} {axiPsSrc[wr][AWREGION][*]}
	ConfigProbe ${ilaName} {axiPsSrc[wr][AWUSER]}
	ConfigProbe ${ilaName} {axiPsSrc[wr][AWVALID]}
	ConfigProbe ${ilaName} {axiPsSrc[wr][WID]}
	ConfigProbe ${ilaName} {axiPsSrc[wr][WDATA][*]}
	ConfigProbe ${ilaName} {axiPsSrc[wr][WSTRB][*]}
	ConfigProbe ${ilaName} {axiPsSrc[wr][WLAST]}
	ConfigProbe ${ilaName} {axiPsSrc[wr][WUSER]}
	ConfigProbe ${ilaName} {axiPsSrc[wr][WVALID]}
	ConfigProbe ${ilaName} {axiPsSrc[wr][BREADY]}

	ConfigProbe ${ilaName} {axiPsDst[wr][AWREADY]}
	ConfigProbe ${ilaName} {axiPsDst[wr][WREADY]}
	ConfigProbe ${ilaName} {axiPsDst[wr][BID]}
	ConfigProbe ${ilaName} {axiPsDst[wr][BRESP][*]}
	ConfigProbe ${ilaName} {axiPsDst[wr][BUSER]}
	ConfigProbe ${ilaName} {axiPsDst[wr][BVALID]}

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