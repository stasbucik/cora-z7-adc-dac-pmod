source -quiet $::env(RUCKUS_DIR)/vivado/env_var.tcl
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

open_run synth_1

set enable 1
if { ${enable} == 1 } {
	set ilaName "u_ila_ps_clk_domain"
	set ilaSize 2048
	set ilaClk "clk"

	CreateDebugCore ${ilaName}
	set_property C_DATA_DEPTH ${ilaSize} [get_debug_cores ${ilaName}]
	SetDebugCoreClk ${ilaName} ${ilaClk}

	#ConfigProbe ${ilaName} {dacSdin}
	#ConfigProbe ${ilaName} {dacSync}
	#ConfigProbe ${ilaName} {dacHighz}
	ConfigProbe ${ilaName} {adcOverflow}
	ConfigProbe ${ilaName} {interrupt}

	################################################
	# axi streams
	#ConfigProbe ${ilaName} {axisDacSrc[TDEST]}
	#ConfigProbe ${ilaName} {axisDacSrc[TID]}
	#ConfigProbe ${ilaName} {axisDacSrc[TLAST]}
	#ConfigProbe ${ilaName} {axisDacSrc[TUSER]}
	#ConfigProbe ${ilaName} {axisDacSrc[TVALID]}
	#ConfigProbe ${ilaName} {axisDacSrc[TWAKEUP]}
	#ConfigProbe ${ilaName} {axisDacSrc[TDATA][*]}
	#ConfigProbe ${ilaName} {axisDacSrc[TKEEP][*]}
	#ConfigProbe ${ilaName} {axisDacSrc[TSTRB][*]}

	#ConfigProbe ${ilaName} {axisDacDst[TREADY]}

	#ConfigProbe ${ilaName} {axisAdcSrc[TDEST]}
	#ConfigProbe ${ilaName} {axisAdcSrc[TID]}
	#ConfigProbe ${ilaName} {axisAdcSrc[TLAST]}
	#ConfigProbe ${ilaName} {axisAdcSrc[TUSER]}
	#ConfigProbe ${ilaName} {axisAdcSrc[TVALID]}
	#ConfigProbe ${ilaName} {axisAdcSrc[TWAKEUP]}
	#ConfigProbe ${ilaName} {axisAdcSrc[TDATA][*]}
	#ConfigProbe ${ilaName} {axisAdcSrc[TKEEP][*]}
	#ConfigProbe ${ilaName} {axisAdcSrc[TSTRB][*]}

	#ConfigProbe ${ilaName} {axisAdcDst[TREADY]}
	################################################
	
	################################################
	# axi4 for my design
	#ConfigProbe ${ilaName} {axiPsSrc[rd][ARID]}
	#ConfigProbe ${ilaName} {axiPsSrc[rd][ARADDR][*]}
	#ConfigProbe ${ilaName} {axiPsSrc[rd][ARLEN][*]}
	#ConfigProbe ${ilaName} {axiPsSrc[rd][ARSIZE][*]}
	#ConfigProbe ${ilaName} {axiPsSrc[rd][ARBURST][*]}
	#ConfigProbe ${ilaName} {axiPsSrc[rd][ARLOCK]}
	#ConfigProbe ${ilaName} {axiPsSrc[rd][ARCACHE][*]}
	#ConfigProbe ${ilaName} {axiPsSrc[rd][ARPROT][*]}
	#ConfigProbe ${ilaName} {axiPsSrc[rd][ARQOS][*]}
	#ConfigProbe ${ilaName} {axiPsSrc[rd][ARREGION][*]}
	#ConfigProbe ${ilaName} {axiPsSrc[rd][ARUSER]}
	#ConfigProbe ${ilaName} {axiPsSrc[rd][ARVALID]}
	#ConfigProbe ${ilaName} {axiPsSrc[rd][RREADY]}

	#ConfigProbe ${ilaName} {axiPsDst[rd][ARREADY]}
	#ConfigProbe ${ilaName} {axiPsDst[rd][RID]}
	#ConfigProbe ${ilaName} {axiPsDst[rd][RDATA][*]}
	#ConfigProbe ${ilaName} {axiPsDst[rd][RRESP][*]}
	#ConfigProbe ${ilaName} {axiPsDst[rd][RLAST]}
	#ConfigProbe ${ilaName} {axiPsDst[rd][RUSER]}
	#ConfigProbe ${ilaName} {axiPsDst[rd][RVALID]}

	#ConfigProbe ${ilaName} {axiPsSrc[wr][AWID]}
	#ConfigProbe ${ilaName} {axiPsSrc[wr][AWADDR][*]}
	#ConfigProbe ${ilaName} {axiPsSrc[wr][AWLEN][*]}
	#ConfigProbe ${ilaName} {axiPsSrc[wr][AWSIZE][*]}
	#ConfigProbe ${ilaName} {axiPsSrc[wr][AWBURST][*]}
	#ConfigProbe ${ilaName} {axiPsSrc[wr][AWLOCK]}
	#ConfigProbe ${ilaName} {axiPsSrc[wr][AWCACHE][*]}
	#ConfigProbe ${ilaName} {axiPsSrc[wr][AWPROT][*]}
	#ConfigProbe ${ilaName} {axiPsSrc[wr][AWQOS][*]}
	#ConfigProbe ${ilaName} {axiPsSrc[wr][AWREGION][*]}
	#ConfigProbe ${ilaName} {axiPsSrc[wr][AWUSER]}
	#ConfigProbe ${ilaName} {axiPsSrc[wr][AWVALID]}
	#ConfigProbe ${ilaName} {axiPsSrc[wr][WID]}
	#ConfigProbe ${ilaName} {axiPsSrc[wr][WDATA][*]}
	#ConfigProbe ${ilaName} {axiPsSrc[wr][WSTRB][*]}
	#ConfigProbe ${ilaName} {axiPsSrc[wr][WLAST]}
	#ConfigProbe ${ilaName} {axiPsSrc[wr][WUSER]}
	#ConfigProbe ${ilaName} {axiPsSrc[wr][WVALID]}
	#ConfigProbe ${ilaName} {axiPsSrc[wr][BREADY]}

	#ConfigProbe ${ilaName} {axiPsDst[wr][AWREADY]}
	#ConfigProbe ${ilaName} {axiPsDst[wr][WREADY]}
	#ConfigProbe ${ilaName} {axiPsDst[wr][BID]}
	#ConfigProbe ${ilaName} {axiPsDst[wr][BRESP][*]}
	#ConfigProbe ${ilaName} {axiPsDst[wr][BUSER]}
	#ConfigProbe ${ilaName} {axiPsDst[wr][BVALID]}
	################################################

	################################################
	# axi4 from fpga
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_ARID[*]}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_ARADDR[*]}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_ARLEN[*]}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_ARSIZE[*]}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_ARBURST[*]}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_ARLOCK[*]}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_ARCACHE[*]}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_ARPROT[*]}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_ARQOS[*]}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_ARVALID}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_RREADY}

	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_ARREADY}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/M_AXI_GP0_RID[*]}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/M_AXI_GP0_RDATA[*]}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/M_AXI_GP0_RRESP[*]}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_RLAST}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_RVALID}

	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_AWID[*]}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_AWADDR[*]}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_AWLEN[*]}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_AWSIZE[*]}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_AWBURST[*]}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_AWLOCK[*]}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_AWCACHE[*]}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_AWPROT[*]}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_AWQOS[*]}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_AWVALID}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_WDATA[*]}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_WSTRB[*]}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_WLAST}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_WVALID}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_BREADY}

	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_AWREADY}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_WREADY}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/M_AXI_GP0_BID[*]}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/M_AXI_GP0_BRESP[*]}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_BVALID}
	################################################
	
	################################################
	# u_BramBufferReader
	#ConfigProbe ${ilaName} {u_DataBuffer/u_BramBufferReader/r[state][*]}
	#ConfigProbe ${ilaName} {u_DataBuffer/u_BramBufferReader/r[addr][*]}
	#ConfigProbe ${ilaName} {u_DataBuffer/u_BramBufferReader/r[len]}
	#ConfigProbe ${ilaName} {u_DataBuffer/u_BramBufferReader/r[transferCounter][*]}
	#ConfigProbe ${ilaName} {u_DataBuffer/u_BramBufferReader/r[latencyCounter]}
	#ConfigProbe ${ilaName} {u_DataBuffer/u_BramBufferReader/r[enables][*]}
	#ConfigProbe ${ilaName} {u_DataBuffer/u_BramBufferReader/r[tmpBuffer][*][*]}
	#ConfigProbe ${ilaName} {u_DataBuffer/u_BramBufferReader/r[readDone]}
	#ConfigProbe ${ilaName} {u_DataBuffer/u_BramBufferReader/r[readingFrom]}

	################################################
	# u_BramBufferWriter
	#ConfigProbe ${ilaName} {u_DataBuffer/u_BramBufferWriter/r[state]}
	#ConfigProbe ${ilaName} {u_DataBuffer/u_BramBufferWriter/r[tready]}
	#ConfigProbe ${ilaName} {u_DataBuffer/u_BramBufferWriter/r[addressCounter][*]}
	#ConfigProbe ${ilaName} {u_DataBuffer/u_BramBufferWriter/r[bufferIndex]}
	#ConfigProbe ${ilaName} {u_DataBuffer/u_BramBufferWriter/r[previousBufferIndex]}
	#ConfigProbe ${ilaName} {u_DataBuffer/u_BramBufferWriter/r[rowCounter][*]}
	#ConfigProbe ${ilaName} {u_DataBuffer/u_BramBufferWriter/r[we][*]}
	#ConfigProbe ${ilaName} {u_DataBuffer/u_BramBufferWriter/r[wrAddr][*]}
	#ConfigProbe ${ilaName} {u_DataBuffer/u_BramBufferWriter/r[wrData][*]}

	################################################
	# u_DataBuffer
	ConfigProbe ${ilaName} {u_DataBuffer/bramWriteSrc0[en]}
	ConfigProbe ${ilaName} {u_DataBuffer/bramWriteSrc0[we]}
	ConfigProbe ${ilaName} {u_DataBuffer/bramWriteSrc0[addr][*]}
	ConfigProbe ${ilaName} {u_DataBuffer/bramWriteSrc0[din][*]}
	ConfigProbe ${ilaName} {u_DataBuffer/bramWriteSrc1[en]}
	ConfigProbe ${ilaName} {u_DataBuffer/bramWriteSrc1[we]}
	ConfigProbe ${ilaName} {u_DataBuffer/bramWriteSrc1[addr][*]}
	ConfigProbe ${ilaName} {u_DataBuffer/bramWriteSrc1[din][*]}
	ConfigProbe ${ilaName} {u_DataBuffer/writingInto}
	ConfigProbe ${ilaName} {u_DataBuffer/bramReadSrc0[en]}
	ConfigProbe ${ilaName} {u_DataBuffer/bramReadSrc0[addr][*]}
	ConfigProbe ${ilaName} {u_DataBuffer/bramReadSrc1[en]}
	ConfigProbe ${ilaName} {u_DataBuffer/bramReadSrc1[addr][*]}
	ConfigProbe ${ilaName} {u_DataBuffer/bramReadDst0[dout][*]}
	ConfigProbe ${ilaName} {u_DataBuffer/bramReadDst1[dout][*]}
	ConfigProbe ${ilaName} {u_DataBuffer/readStart}
	ConfigProbe ${ilaName} {u_DataBuffer/address[*]}
	ConfigProbe ${ilaName} {u_DataBuffer/length}
	ConfigProbe ${ilaName} {u_DataBuffer/readDone}
	ConfigProbe ${ilaName} {u_DataBuffer/counter[*]}
	ConfigProbe ${ilaName} {u_DataBuffer/dataBuffer[*][*]}
	ConfigProbe ${ilaName} {u_DataBuffer/readingFrom}
	ConfigProbe ${ilaName} {u_DataBuffer/interruptDelayed}
	ConfigProbe ${ilaName} {u_DataBuffer/counterAdapter[*]}


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