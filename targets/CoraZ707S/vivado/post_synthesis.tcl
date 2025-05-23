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

	#ConfigProbe ${ilaName} {dacSdin}
	#ConfigProbe ${ilaName} {dacSync}
	#ConfigProbe ${ilaName} {dacHighz}
	#ConfigProbe ${ilaName} {adcOverflow}
	#ConfigProbe ${ilaName} {interruptFast}
	#ConfigProbe ${ilaName} {interrupt}
	#ConfigProbe ${ilaName} {clearBuffer}
	#ConfigProbe ${ilaName} {clearBufferFast}
	#ConfigProbe ${ilaName} {updateStat}
	#ConfigProbe ${ilaName} {overwrite}
	#ConfigProbe ${ilaName} {overwriteLatch}
	#ConfigProbe ${ilaName} {clearOverwrite}
	#ConfigProbe ${ilaName} {ctrlReg[*]}
	#ConfigProbe ${ilaName} {statReg[*]}
	#ConfigProbe ${ilaName} {newStatReg[*]}
	#ConfigProbe ${ilaName} {u_AdcMAX11105/run_i}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/xlconcat_1_dout[*]}

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
	# axi4 for reading buffer
	#ConfigProbe ${ilaName} {axiBufferSrc[rd][ARID]}
	#ConfigProbe ${ilaName} {axiBufferSrc[rd][ARADDR][*]}
	#ConfigProbe ${ilaName} {axiBufferSrc[rd][ARLEN][*]}
	#ConfigProbe ${ilaName} {axiBufferSrc[rd][ARSIZE][*]}
	#ConfigProbe ${ilaName} {axiBufferSrc[rd][ARBURST][*]}
	#ConfigProbe ${ilaName} {axiBufferSrc[rd][ARLOCK]}
	#ConfigProbe ${ilaName} {axiBufferSrc[rd][ARCACHE][*]}
	#ConfigProbe ${ilaName} {axiBufferSrc[rd][ARPROT][*]}
	#ConfigProbe ${ilaName} {axiBufferSrc[rd][ARQOS][*]}
	#ConfigProbe ${ilaName} {axiBufferSrc[rd][ARREGION][*]}
	#ConfigProbe ${ilaName} {axiBufferSrc[rd][ARUSER]}
	#ConfigProbe ${ilaName} {axiBufferSrc[rd][ARVALID]}
	#ConfigProbe ${ilaName} {axiBufferSrc[rd][RREADY]}

	#ConfigProbe ${ilaName} {axiBufferDst[rd][ARREADY]}
	#ConfigProbe ${ilaName} {axiBufferDst[rd][RID]}
	#ConfigProbe ${ilaName} {axiBufferDst[rd][RDATA][*]}
	#ConfigProbe ${ilaName} {axiBufferDst[rd][RRESP][*]}
	#ConfigProbe ${ilaName} {axiBufferDst[rd][RLAST]}
	#ConfigProbe ${ilaName} {axiBufferDst[rd][RUSER]}
	#ConfigProbe ${ilaName} {axiBufferDst[rd][RVALID]}
	################################################

	################################################
	# axi4 for control
	#ConfigProbe ${ilaName} {axiCtrlSrc[rd][ARID]}
	#ConfigProbe ${ilaName} {axiCtrlSrc[rd][ARADDR][*]}
	#ConfigProbe ${ilaName} {axiCtrlSrc[rd][ARLEN][*]}
	#ConfigProbe ${ilaName} {axiCtrlSrc[rd][ARSIZE][*]}
	#ConfigProbe ${ilaName} {axiCtrlSrc[rd][ARBURST][*]}
	#ConfigProbe ${ilaName} {axiCtrlSrc[rd][ARLOCK]}
	#ConfigProbe ${ilaName} {axiCtrlSrc[rd][ARCACHE][*]}
	#ConfigProbe ${ilaName} {axiCtrlSrc[rd][ARPROT][*]}
	#ConfigProbe ${ilaName} {axiCtrlSrc[rd][ARQOS][*]}
	#ConfigProbe ${ilaName} {axiCtrlSrc[rd][ARREGION][*]}
	#ConfigProbe ${ilaName} {axiCtrlSrc[rd][ARUSER]}
	#ConfigProbe ${ilaName} {axiCtrlSrc[rd][ARVALID]}
	#ConfigProbe ${ilaName} {axiCtrlSrc[rd][RREADY]}

	#ConfigProbe ${ilaName} {axiCtrlDst[rd][ARREADY]}
	#ConfigProbe ${ilaName} {axiCtrlDst[rd][RID]}
	#ConfigProbe ${ilaName} {axiCtrlDst[rd][RDATA][*]}
	#ConfigProbe ${ilaName} {axiCtrlDst[rd][RRESP][*]}
	#ConfigProbe ${ilaName} {axiCtrlDst[rd][RLAST]}
	#ConfigProbe ${ilaName} {axiCtrlDst[rd][RUSER]}
	#ConfigProbe ${ilaName} {axiCtrlDst[rd][RVALID]}

	#ConfigProbe ${ilaName} {axiCtrlSrc[wr][AWID]}
	#ConfigProbe ${ilaName} {axiCtrlSrc[wr][AWADDR][*]}
	#ConfigProbe ${ilaName} {axiCtrlSrc[wr][AWLEN][*]}
	#ConfigProbe ${ilaName} {axiCtrlSrc[wr][AWSIZE][*]}
	#ConfigProbe ${ilaName} {axiCtrlSrc[wr][AWBURST][*]}
	#ConfigProbe ${ilaName} {axiCtrlSrc[wr][AWLOCK]}
	#ConfigProbe ${ilaName} {axiCtrlSrc[wr][AWCACHE][*]}
	#ConfigProbe ${ilaName} {axiCtrlSrc[wr][AWPROT][*]}
	#ConfigProbe ${ilaName} {axiCtrlSrc[wr][AWQOS][*]}
	#ConfigProbe ${ilaName} {axiCtrlSrc[wr][AWREGION][*]}
	#ConfigProbe ${ilaName} {axiCtrlSrc[wr][AWUSER]}
	#ConfigProbe ${ilaName} {axiCtrlSrc[wr][AWVALID]}
	#ConfigProbe ${ilaName} {axiCtrlSrc[wr][WID]}
	#ConfigProbe ${ilaName} {axiCtrlSrc[wr][WDATA][*]}
	#ConfigProbe ${ilaName} {axiCtrlSrc[wr][WSTRB][*]}
	#ConfigProbe ${ilaName} {axiCtrlSrc[wr][WLAST]}
	#ConfigProbe ${ilaName} {axiCtrlSrc[wr][WUSER]}
	#ConfigProbe ${ilaName} {axiCtrlSrc[wr][WVALID]}
	#ConfigProbe ${ilaName} {axiCtrlSrc[wr][BREADY]}

	#ConfigProbe ${ilaName} {axiCtrlDst[wr][AWREADY]}
	#ConfigProbe ${ilaName} {axiCtrlDst[wr][WREADY]}
	#ConfigProbe ${ilaName} {axiCtrlDst[wr][BID]}
	#ConfigProbe ${ilaName} {axiCtrlDst[wr][BRESP][*]}
	#ConfigProbe ${ilaName} {axiCtrlDst[wr][BUSER]}
	#ConfigProbe ${ilaName} {axiCtrlDst[wr][BVALID]}
	################################################

	################################################
	# axi4 for status
	#ConfigProbe ${ilaName} {axiStatSrc[rd][ARID]}
	#ConfigProbe ${ilaName} {axiStatSrc[rd][ARADDR][*]}
	#ConfigProbe ${ilaName} {axiStatSrc[rd][ARLEN][*]}
	#ConfigProbe ${ilaName} {axiStatSrc[rd][ARSIZE][*]}
	#ConfigProbe ${ilaName} {axiStatSrc[rd][ARBURST][*]}
	#ConfigProbe ${ilaName} {axiStatSrc[rd][ARLOCK]}
	#ConfigProbe ${ilaName} {axiStatSrc[rd][ARCACHE][*]}
	#ConfigProbe ${ilaName} {axiStatSrc[rd][ARPROT][*]}
	#ConfigProbe ${ilaName} {axiStatSrc[rd][ARQOS][*]}
	#ConfigProbe ${ilaName} {axiStatSrc[rd][ARREGION][*]}
	#ConfigProbe ${ilaName} {axiStatSrc[rd][ARUSER]}
	#ConfigProbe ${ilaName} {axiStatSrc[rd][ARVALID]}
	#ConfigProbe ${ilaName} {axiStatSrc[rd][RREADY]}

	#ConfigProbe ${ilaName} {axiStatDst[rd][ARREADY]}
	#ConfigProbe ${ilaName} {axiStatDst[rd][RID]}
	#ConfigProbe ${ilaName} {axiStatDst[rd][RDATA][*]}
	#ConfigProbe ${ilaName} {axiStatDst[rd][RRESP][*]}
	#ConfigProbe ${ilaName} {axiStatDst[rd][RLAST]}
	#ConfigProbe ${ilaName} {axiStatDst[rd][RUSER]}
	#ConfigProbe ${ilaName} {axiStatDst[rd][RVALID]}
	################################################

	################################################
	# axi4 from fpga
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_ARID[*]}
	ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_ARADDR[*]}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_ARLEN[*]}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_ARSIZE[*]}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_ARBURST[*]}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_ARLOCK[*]}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_ARCACHE[*]}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_ARPROT[*]}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_ARQOS[*]}
	ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_ARVALID}
	ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_RREADY}

	ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_ARREADY}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/M_AXI_GP0_RID[*]}
	ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/M_AXI_GP0_RDATA[*]}
	ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/M_AXI_GP0_RRESP[*]}
	ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_RLAST}
	ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_RVALID}

	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_AWID[*]}
	ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_AWADDR[*]}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_AWLEN[*]}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_AWSIZE[*]}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_AWBURST[*]}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_AWLOCK[*]}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_AWCACHE[*]}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_AWPROT[*]}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_AWQOS[*]}
	ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_AWVALID}
	ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_WDATA[*]}
	ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_WSTRB[*]}
	ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_WLAST}
	ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_WVALID}
	ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_BREADY}

	ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_AWREADY}
	ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_WREADY}
	#ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/M_AXI_GP0_BID[*]}
	ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/M_AXI_GP0_BRESP[*]}
	ConfigProbe ${ilaName} {u_InfrastructureTop/u_Infrastructure_wrapper/Infrastructure_i/processing_system7_0_M_AXI_GP0_BVALID}
	################################################
	
	################################################
	# u_BramBufferReader
	#ConfigProbe ${ilaName} {u_DataBuffer/u_BramBufferReader/r[state][*]}
	#ConfigProbe ${ilaName} {u_DataBuffer/u_BramBufferReader/r[addr][*]}
	#ConfigProbe ${ilaName} {u_DataBuffer/u_BramBufferReader/r[len][*]}
	#ConfigProbe ${ilaName} {u_DataBuffer/u_BramBufferReader/r[transferCounter][*]}
	#ConfigProbe ${ilaName} {u_DataBuffer/u_BramBufferReader/r[latencyCounter]}
	#ConfigProbe ${ilaName} {u_DataBuffer/u_BramBufferReader/r[enables][*]}
	#ConfigProbe ${ilaName} {u_DataBuffer/u_BramBufferReader/r[tmpBuffer][*][*]}
	#ConfigProbe ${ilaName} {u_DataBuffer/u_BramBufferReader/r[readDone]}
	#ConfigProbe ${ilaName} {u_DataBuffer/u_BramBufferReader/r[readingFrom]}
	#ConfigProbe ${ilaName} {u_DataBuffer/u_BramBufferReader/r[readingFromStart]}
	#ConfigProbe ${ilaName} {u_DataBuffer/u_BramBufferReader/r[overwrite]}
	#ConfigProbe ${ilaName} {u_DataBuffer/u_BramBufferReader/r[clearOverwrite]}


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
	#ConfigProbe ${ilaName} {u_DataBuffer/bramWriteSrc0[en]}
	#ConfigProbe ${ilaName} {u_DataBuffer/bramWriteSrc0[we]}
	#ConfigProbe ${ilaName} {u_DataBuffer/bramWriteSrc0[addr][*]}
	#ConfigProbe ${ilaName} {u_DataBuffer/bramWriteSrc0[din][*]}
	#ConfigProbe ${ilaName} {u_DataBuffer/bramWriteSrc1[en]}
	#ConfigProbe ${ilaName} {u_DataBuffer/bramWriteSrc1[we]}
	#ConfigProbe ${ilaName} {u_DataBuffer/bramWriteSrc1[addr][*]}
	#ConfigProbe ${ilaName} {u_DataBuffer/bramWriteSrc1[din][*]}
	#ConfigProbe ${ilaName} {u_DataBuffer/writingInto}
	#ConfigProbe ${ilaName} {u_DataBuffer/bramReadSrc0[en]}
	#ConfigProbe ${ilaName} {u_DataBuffer/bramReadSrc0[addr][*]}
	#ConfigProbe ${ilaName} {u_DataBuffer/bramReadSrc1[en]}
	#ConfigProbe ${ilaName} {u_DataBuffer/bramReadSrc1[addr][*]}
	#ConfigProbe ${ilaName} {u_DataBuffer/bramReadDst0[dout][*]}
	#ConfigProbe ${ilaName} {u_DataBuffer/bramReadDst1[dout][*]}
	#ConfigProbe ${ilaName} {u_DataBuffer/readStart}
	#ConfigProbe ${ilaName} {u_DataBuffer/address[*]}
	#ConfigProbe ${ilaName} {u_DataBuffer/length[*]}
	#ConfigProbe ${ilaName} {u_DataBuffer/readDone}
	#ConfigProbe ${ilaName} {u_DataBuffer/counter[*]}
	#ConfigProbe ${ilaName} {u_DataBuffer/dataBuffer[*][*]}
	#ConfigProbe ${ilaName} {u_DataBuffer/readingFrom}
	#ConfigProbe ${ilaName} {u_DataBuffer/interruptDelayed}


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

	ConfigProbe ${ilaName} {u_AdcMAX11105/asyncSpi_g.u_SpiMaster/u_SpiMaster2Axis/r[rdBuffer][*]}
	ConfigProbe ${ilaName} {u_AdcMAX11105/asyncSpi_g.u_SpiMaster/u_SpiMaster2Axis/r[rdCounter][*]}
	ConfigProbe ${ilaName} {u_AdcMAX11105/asyncSpi_g.u_SpiMaster/u_SpiMaster2Axis/r[transferDone]}
	ConfigProbe ${ilaName} {u_AdcMAX11105/asyncSpi_g.u_SpiMaster/u_SpiMaster2Axis/r[overflow]}

	################################################
	# u_SpiMaster
	ConfigProbe ${ilaName} {u_AdcMAX11105/asyncSpi_g.u_SpiMaster/syncRst}
	ConfigProbe ${ilaName} {u_AdcMAX11105/asyncSpi_g.u_SpiMaster/syncClear}
	ConfigProbe ${ilaName} {u_AdcMAX11105/asyncSpi_g.u_SpiMaster/syncOverflow}
	ConfigProbe ${ilaName} {u_AdcMAX11105/asyncSpi_g.u_SpiMaster/syncRun}
	ConfigProbe ${ilaName} {u_AdcMAX11105/asyncSpi_g.u_SpiMaster/g_syncRead.u_syncRead/s_aresetn}

	#ConfigProbe ${ilaName} {u_AdcMAX11105/asyncSpi_g.u_SpiMaster/axisWriteSrcSlow[TDEST]}
	#ConfigProbe ${ilaName} {u_AdcMAX11105/asyncSpi_g.u_SpiMaster/axisWriteSrcSlow[TID]}
	ConfigProbe ${ilaName} {u_AdcMAX11105/asyncSpi_g.u_SpiMaster/axisWriteSrcSlow[TLAST]}
	#ConfigProbe ${ilaName} {u_AdcMAX11105/asyncSpi_g.u_SpiMaster/axisWriteSrcSlow[TUSER]}
	ConfigProbe ${ilaName} {u_AdcMAX11105/asyncSpi_g.u_SpiMaster/axisWriteSrcSlow[TVALID]}
	#ConfigProbe ${ilaName} {u_AdcMAX11105/asyncSpi_g.u_SpiMaster/axisWriteSrcSlow[TWAKEUP]}
	ConfigProbe ${ilaName} {u_AdcMAX11105/asyncSpi_g.u_SpiMaster/axisWriteSrcSlow[TDATA][*]}
	#ConfigProbe ${ilaName} {u_AdcMAX11105/asyncSpi_g.u_SpiMaster/axisWriteSrcSlow[TKEEP][*]}
	#ConfigProbe ${ilaName} {u_AdcMAX11105/asyncSpi_g.u_SpiMaster/axisWriteSrcSlow[TSTRB][*]}

	ConfigProbe ${ilaName} {u_AdcMAX11105/asyncSpi_g.u_SpiMaster/axisWriteDstSlow[TREADY]}

	#ConfigProbe ${ilaName} {u_AdcMAX11105/asyncSpi_g.u_SpiMaster/axisReadSrcSlow[TDEST]}
	#ConfigProbe ${ilaName} {u_AdcMAX11105/asyncSpi_g.u_SpiMaster/axisReadSrcSlow[TID]}
	ConfigProbe ${ilaName} {u_AdcMAX11105/asyncSpi_g.u_SpiMaster/axisReadSrcSlow[TLAST]}
	#ConfigProbe ${ilaName} {u_AdcMAX11105/asyncSpi_g.u_SpiMaster/axisReadSrcSlow[TUSER]}
	ConfigProbe ${ilaName} {u_AdcMAX11105/asyncSpi_g.u_SpiMaster/axisReadSrcSlow[TVALID]}
	#ConfigProbe ${ilaName} {u_AdcMAX11105/asyncSpi_g.u_SpiMaster/axisReadSrcSlow[TWAKEUP]}
	ConfigProbe ${ilaName} {u_AdcMAX11105/asyncSpi_g.u_SpiMaster/axisReadSrcSlow[TDATA][*]}
	#ConfigProbe ${ilaName} {u_AdcMAX11105/asyncSpi_g.u_SpiMaster/axisReadSrcSlow[TKEEP][*]}
	#ConfigProbe ${ilaName} {u_AdcMAX11105/asyncSpi_g.u_SpiMaster/axisReadSrcSlow[TSTRB][*]}

	ConfigProbe ${ilaName} {u_AdcMAX11105/asyncSpi_g.u_SpiMaster/axisReadDstSlow[TREADY]}

	ConfigProbe ${ilaName} {u_AdcMAX11105/asyncSpi_g.u_SpiMaster/wr_rst_busyRead}
	ConfigProbe ${ilaName} {u_AdcMAX11105/asyncSpi_g.u_SpiMaster/rd_rst_busyRead}


	WriteDebugProbes ${ilaName} ${PROJ_DIR}/images/debug_probes.ltx
}