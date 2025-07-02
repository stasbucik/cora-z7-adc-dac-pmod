----------------------------------------------------------------------------------
--  Copyright 2025, University of Ljubljana
--
--  This file is part of cora-z7-adc-dac-pmod.
--  cora-z7-adc-dac-pmod is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by the Free Software Foundation,
--  either version 3 of the License, or any later version.
--  cora-z7-adc-dac-pmod is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
--  FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
--  You should have received a copy of the GNU General Public License along with cora-z7-adc-dac-pmod.
--  If not, see <https://www.gnu.org/licenses/>. 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

use work.Axi4Pkg.all;
entity InfrastructureTop is
     port (
          DDR_addr          : inout STD_LOGIC_VECTOR ( 14 downto 0 );
          DDR_ba            : inout STD_LOGIC_VECTOR ( 2 downto 0 );
          DDR_cas_n         : inout STD_LOGIC;
          DDR_ck_n          : inout STD_LOGIC;
          DDR_ck_p          : inout STD_LOGIC;
          DDR_cke           : inout STD_LOGIC;
          DDR_cs_n          : inout STD_LOGIC;
          DDR_dm            : inout STD_LOGIC_VECTOR ( 3 downto 0 );
          DDR_dq            : inout STD_LOGIC_VECTOR ( 31 downto 0 );
          DDR_dqs_n         : inout STD_LOGIC_VECTOR ( 3 downto 0 );
          DDR_dqs_p         : inout STD_LOGIC_VECTOR ( 3 downto 0 );
          DDR_odt           : inout STD_LOGIC;
          DDR_ras_n         : inout STD_LOGIC;
          DDR_reset_n       : inout STD_LOGIC;
          DDR_we_n          : inout STD_LOGIC;
          FIXED_IO_ddr_vrn  : inout STD_LOGIC;
          FIXED_IO_ddr_vrp  : inout STD_LOGIC;
          FIXED_IO_mio      : inout STD_LOGIC_VECTOR ( 53 downto 0 );
          FIXED_IO_ps_clk   : inout STD_LOGIC;
          FIXED_IO_ps_porb  : inout STD_LOGIC;
          FIXED_IO_ps_srstb : inout STD_LOGIC;
          IRQ_F2P           : in    STD_LOGIC;
          axiBufferSrc      : out   Axi4Source;
          axiBufferDst      : in    Axi4Destination;
          axiCtrlSrc        : out   Axi4Source;
          axiCtrlDst        : in    Axi4Destination;
          axiStatSrc        : out   Axi4Source;
          axiStatDst        : in    Axi4Destination;
          peripheral_reset  : out   STD_LOGIC;
          spi_clk           : out   STD_LOGIC;
          ps_clk            : out   STD_LOGIC
     );
end InfrastructureTop;

architecture STRUCTURE of InfrastructureTop is

     signal rstAdapter : STD_LOGIC_VECTOR(0 downto 0);
     signal intAdapter : STD_LOGIC_VECTOR(0 downto 0);

begin
     u_Infrastructure_wrapper : entity work.Infrastructure_wrapper
          port map (
               DDR_addr          => DDR_addr,
               DDR_ba            => DDR_ba,
               DDR_cas_n         => DDR_cas_n,
               DDR_ck_n          => DDR_ck_n,
               DDR_ck_p          => DDR_ck_p,
               DDR_cke           => DDR_cke,
               DDR_cs_n          => DDR_cs_n,
               DDR_dm            => DDR_dm,
               DDR_dq            => DDR_dq,
               DDR_dqs_n         => DDR_dqs_n,
               DDR_dqs_p         => DDR_dqs_p,
               DDR_odt           => DDR_odt,
               DDR_ras_n         => DDR_ras_n,
               DDR_reset_n       => DDR_reset_n,
               DDR_we_n          => DDR_we_n,
               FIXED_IO_ddr_vrn  => FIXED_IO_ddr_vrn,
               FIXED_IO_ddr_vrp  => FIXED_IO_ddr_vrp,
               FIXED_IO_mio      => FIXED_IO_mio,
               FIXED_IO_ps_clk   => FIXED_IO_ps_clk,
               FIXED_IO_ps_porb  => FIXED_IO_ps_porb,
               FIXED_IO_ps_srstb => FIXED_IO_ps_srstb,
               IRQ_F2P           => intAdapter,

               M_AXI_buffer_araddr  => axiBufferSrc.rd.araddr,
               M_AXI_buffer_arburst => axiBufferSrc.rd.arburst,
               M_AXI_buffer_arcache => axiBufferSrc.rd.arcache,
               M_AXI_buffer_arlen   => axiBufferSrc.rd.arlen,
               M_AXI_buffer_arlock  => axiBufferSrc.rd.arlock,
               M_AXI_buffer_arprot  => axiBufferSrc.rd.arprot,
               M_AXI_buffer_arqos   => axiBufferSrc.rd.arqos,
               M_AXI_buffer_arready => axiBufferDst.rd.arready,
               M_AXI_buffer_arsize  => axiBufferSrc.rd.arsize,
               M_AXI_buffer_arvalid => axiBufferSrc.rd.arvalid,
               M_AXI_buffer_awaddr  => axiBufferSrc.wr.awaddr,
               M_AXI_buffer_awburst => axiBufferSrc.wr.awburst,
               M_AXI_buffer_awcache => axiBufferSrc.wr.awcache,
               M_AXI_buffer_awlen   => axiBufferSrc.wr.awlen,
               M_AXI_buffer_awlock  => axiBufferSrc.wr.awlock,
               M_AXI_buffer_awprot  => axiBufferSrc.wr.awprot,
               M_AXI_buffer_awqos   => axiBufferSrc.wr.awqos,
               M_AXI_buffer_awready => axiBufferDst.wr.awready,
               M_AXI_buffer_awsize  => axiBufferSrc.wr.awsize,
               M_AXI_buffer_awvalid => axiBufferSrc.wr.awvalid,
               M_AXI_buffer_bready  => axiBufferSrc.wr.bready,
               M_AXI_buffer_bresp   => axiBufferDst.wr.bresp,
               M_AXI_buffer_bvalid  => axiBufferDst.wr.bvalid,
               M_AXI_buffer_rdata   => axiBufferDst.rd.rdata,
               M_AXI_buffer_rlast   => axiBufferDst.rd.rlast,
               M_AXI_buffer_rready  => axiBufferSrc.rd.rready,
               M_AXI_buffer_rresp   => axiBufferDst.rd.rresp,
               M_AXI_buffer_rvalid  => axiBufferDst.rd.rvalid,
               M_AXI_buffer_wdata   => axiBufferSrc.wr.wdata,
               M_AXI_buffer_wlast   => axiBufferSrc.wr.wlast,
               M_AXI_buffer_wready  => axiBufferDst.wr.wready,
               M_AXI_buffer_wstrb   => axiBufferSrc.wr.wstrb,
               M_AXI_buffer_wvalid  => axiBufferSrc.wr.wvalid,

               M_AXI_ctrl_araddr  => axiCtrlSrc.rd.araddr,
               M_AXI_ctrl_arburst => axiCtrlSrc.rd.arburst,
               M_AXI_ctrl_arcache => axiCtrlSrc.rd.arcache,
               M_AXI_ctrl_arlen   => axiCtrlSrc.rd.arlen,
               M_AXI_ctrl_arlock  => axiCtrlSrc.rd.arlock,
               M_AXI_ctrl_arprot  => axiCtrlSrc.rd.arprot,
               M_AXI_ctrl_arqos   => axiCtrlSrc.rd.arqos,
               M_AXI_ctrl_arready => axiCtrlDst.rd.arready,
               M_AXI_ctrl_arsize  => axiCtrlSrc.rd.arsize,
               M_AXI_ctrl_arvalid => axiCtrlSrc.rd.arvalid,
               M_AXI_ctrl_awaddr  => axiCtrlSrc.wr.awaddr,
               M_AXI_ctrl_awburst => axiCtrlSrc.wr.awburst,
               M_AXI_ctrl_awcache => axiCtrlSrc.wr.awcache,
               M_AXI_ctrl_awlen   => axiCtrlSrc.wr.awlen,
               M_AXI_ctrl_awlock  => axiCtrlSrc.wr.awlock,
               M_AXI_ctrl_awprot  => axiCtrlSrc.wr.awprot,
               M_AXI_ctrl_awqos   => axiCtrlSrc.wr.awqos,
               M_AXI_ctrl_awready => axiCtrlDst.wr.awready,
               M_AXI_ctrl_awsize  => axiCtrlSrc.wr.awsize,
               M_AXI_ctrl_awvalid => axiCtrlSrc.wr.awvalid,
               M_AXI_ctrl_bready  => axiCtrlSrc.wr.bready,
               M_AXI_ctrl_bresp   => axiCtrlDst.wr.bresp,
               M_AXI_ctrl_bvalid  => axiCtrlDst.wr.bvalid,
               M_AXI_ctrl_rdata   => axiCtrlDst.rd.rdata,
               M_AXI_ctrl_rlast   => axiCtrlDst.rd.rlast,
               M_AXI_ctrl_rready  => axiCtrlSrc.rd.rready,
               M_AXI_ctrl_rresp   => axiCtrlDst.rd.rresp,
               M_AXI_ctrl_rvalid  => axiCtrlDst.rd.rvalid,
               M_AXI_ctrl_wdata   => axiCtrlSrc.wr.wdata,
               M_AXI_ctrl_wlast   => axiCtrlSrc.wr.wlast,
               M_AXI_ctrl_wready  => axiCtrlDst.wr.wready,
               M_AXI_ctrl_wstrb   => axiCtrlSrc.wr.wstrb,
               M_AXI_ctrl_wvalid  => axiCtrlSrc.wr.wvalid,

               M_AXI_stat_araddr  => axiStatSrc.rd.araddr,
               M_AXI_stat_arburst => axiStatSrc.rd.arburst,
               M_AXI_stat_arcache => axiStatSrc.rd.arcache,
               M_AXI_stat_arlen   => axiStatSrc.rd.arlen,
               M_AXI_stat_arlock  => axiStatSrc.rd.arlock,
               M_AXI_stat_arprot  => axiStatSrc.rd.arprot,
               M_AXI_stat_arqos   => axiStatSrc.rd.arqos,
               M_AXI_stat_arready => axiStatDst.rd.arready,
               M_AXI_stat_arsize  => axiStatSrc.rd.arsize,
               M_AXI_stat_arvalid => axiStatSrc.rd.arvalid,
               M_AXI_stat_awaddr  => axiStatSrc.wr.awaddr,
               M_AXI_stat_awburst => axiStatSrc.wr.awburst,
               M_AXI_stat_awcache => axiStatSrc.wr.awcache,
               M_AXI_stat_awlen   => axiStatSrc.wr.awlen,
               M_AXI_stat_awlock  => axiStatSrc.wr.awlock,
               M_AXI_stat_awprot  => axiStatSrc.wr.awprot,
               M_AXI_stat_awqos   => axiStatSrc.wr.awqos,
               M_AXI_stat_awready => axiStatDst.wr.awready,
               M_AXI_stat_awsize  => axiStatSrc.wr.awsize,
               M_AXI_stat_awvalid => axiStatSrc.wr.awvalid,
               M_AXI_stat_bready  => axiStatSrc.wr.bready,
               M_AXI_stat_bresp   => axiStatDst.wr.bresp,
               M_AXI_stat_bvalid  => axiStatDst.wr.bvalid,
               M_AXI_stat_rdata   => axiStatDst.rd.rdata,
               M_AXI_stat_rlast   => axiStatDst.rd.rlast,
               M_AXI_stat_rready  => axiStatSrc.rd.rready,
               M_AXI_stat_rresp   => axiStatDst.rd.rresp,
               M_AXI_stat_rvalid  => axiStatDst.rd.rvalid,
               M_AXI_stat_wdata   => axiStatSrc.wr.wdata,
               M_AXI_stat_wlast   => axiStatSrc.wr.wlast,
               M_AXI_stat_wready  => axiStatDst.wr.wready,
               M_AXI_stat_wstrb   => axiStatSrc.wr.wstrb,
               M_AXI_stat_wvalid  => axiStatSrc.wr.wvalid,

               peripheral_reset => rstAdapter,
               ps_clk           => ps_clk,
               spi_clk          => spi_clk
          );

     peripheral_reset <= rstAdapter(0);
     intAdapter       <= (others => IRQ_F2P);
end STRUCTURE;
