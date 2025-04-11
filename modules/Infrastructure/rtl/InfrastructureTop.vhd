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
          axiPsSrc          : out   Axi4Source;
          axiPsDst          : in    Axi4Destination;
          Shield_I2C_scl_io : inout STD_LOGIC;
          Shield_I2C_sda_io : inout STD_LOGIC;
          Shield_SPI_io0_io : inout STD_LOGIC;
          Shield_SPI_io1_io : inout STD_LOGIC;
          Shield_SPI_sck_io : inout STD_LOGIC;
          Shield_SPI_ss_io  : inout STD_LOGIC;
          peripheral_reset  : out   STD_LOGIC;
          ps_clk            : out   STD_LOGIC;
          vaux0_v_n         : in    STD_LOGIC;
          vaux0_v_p         : in    STD_LOGIC;
          vaux12_v_n        : in    STD_LOGIC;
          vaux12_v_p        : in    STD_LOGIC;
          vaux13_v_n        : in    STD_LOGIC;
          vaux13_v_p        : in    STD_LOGIC;
          vaux15_v_n        : in    STD_LOGIC;
          vaux15_v_p        : in    STD_LOGIC;
          vaux1_v_n         : in    STD_LOGIC;
          vaux1_v_p         : in    STD_LOGIC;
          vaux5_v_n         : in    STD_LOGIC;
          vaux5_v_p         : in    STD_LOGIC;
          vaux6_v_n         : in    STD_LOGIC;
          vaux6_v_p         : in    STD_LOGIC;
          vaux8_v_n         : in    STD_LOGIC;
          vaux8_v_p         : in    STD_LOGIC;
          vaux9_v_n         : in    STD_LOGIC;
          vaux9_v_p         : in    STD_LOGIC;
          vp_vn_v_n         : in    STD_LOGIC;
          vp_vn_v_p         : in    STD_LOGIC
     );
end InfrastructureTop;

architecture STRUCTURE of InfrastructureTop is

     signal rstAdapter : STD_LOGIC_VECTOR(0 downto 0);

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
               M_AXI_ps_araddr   => axiPsSrc.rd.araddr,
               M_AXI_ps_arburst  => axiPsSrc.rd.arburst,
               M_AXI_ps_arcache  => axiPsSrc.rd.arcache,
               M_AXI_ps_arlen    => axiPsSrc.rd.arlen,
               M_AXI_ps_arlock   => axiPsSrc.rd.arlock,
               M_AXI_ps_arprot   => axiPsSrc.rd.arprot,
               M_AXI_ps_arqos    => axiPsSrc.rd.arqos,
               M_AXI_ps_arready  => axiPsDst.rd.arready,
               M_AXI_ps_arsize   => axiPsSrc.rd.arsize,
               M_AXI_ps_arvalid  => axiPsSrc.rd.arvalid,
               M_AXI_ps_awaddr   => axiPsSrc.wr.awaddr,
               M_AXI_ps_awburst  => axiPsSrc.wr.awburst,
               M_AXI_ps_awcache  => axiPsSrc.wr.awcache,
               M_AXI_ps_awlen    => axiPsSrc.wr.awlen,
               M_AXI_ps_awlock   => axiPsSrc.wr.awlock,
               M_AXI_ps_awprot   => axiPsSrc.wr.awprot,
               M_AXI_ps_awqos    => axiPsSrc.wr.awqos,
               M_AXI_ps_awready  => axiPsDst.wr.awready,
               M_AXI_ps_awsize   => axiPsSrc.wr.awsize,
               M_AXI_ps_awvalid  => axiPsSrc.wr.awvalid,
               M_AXI_ps_bready   => axiPsSrc.wr.bready,
               M_AXI_ps_bresp    => axiPsDst.wr.bresp,
               M_AXI_ps_bvalid   => axiPsDst.wr.bvalid,
               M_AXI_ps_rdata    => axiPsDst.rd.rdata,
               M_AXI_ps_rlast    => axiPsDst.rd.rlast,
               M_AXI_ps_rready   => axiPsSrc.rd.rready,
               M_AXI_ps_rresp    => axiPsDst.rd.rresp,
               M_AXI_ps_rvalid   => axiPsDst.rd.rvalid,
               M_AXI_ps_wdata    => axiPsSrc.wr.wdata,
               M_AXI_ps_wlast    => axiPsSrc.wr.wlast,
               M_AXI_ps_wready   => axiPsDst.wr.wready,
               M_AXI_ps_wstrb    => axiPsSrc.wr.wstrb,
               M_AXI_ps_wvalid   => axiPsSrc.wr.wvalid,
               Shield_I2C_scl_io => Shield_I2C_scl_io,
               Shield_I2C_sda_io => Shield_I2C_sda_io,
               Shield_SPI_io0_io => Shield_SPI_io0_io,
               Shield_SPI_io1_io => Shield_SPI_io1_io,
               Shield_SPI_sck_io => Shield_SPI_sck_io,
               Shield_SPI_ss_io  => Shield_SPI_ss_io,
               peripheral_reset  => rstAdapter,
               ps_clk            => ps_clk,
               vaux0_v_n         => vaux0_v_n,
               vaux0_v_p         => vaux0_v_p,
               vaux12_v_n        => vaux12_v_n,
               vaux12_v_p        => vaux12_v_p,
               vaux13_v_n        => vaux13_v_n,
               vaux13_v_p        => vaux13_v_p,
               vaux15_v_n        => vaux15_v_n,
               vaux15_v_p        => vaux15_v_p,
               vaux1_v_n         => vaux1_v_n,
               vaux1_v_p         => vaux1_v_p,
               vaux5_v_n         => vaux5_v_n,
               vaux5_v_p         => vaux5_v_p,
               vaux6_v_n         => vaux6_v_n,
               vaux6_v_p         => vaux6_v_p,
               vaux8_v_n         => vaux8_v_n,
               vaux8_v_p         => vaux8_v_p,
               vaux9_v_n         => vaux9_v_n,
               vaux9_v_p         => vaux9_v_p,
               vp_vn_v_n         => vp_vn_v_n,
               vp_vn_v_p         => vp_vn_v_p
          );

     peripheral_reset <= rstAdapter(0);
end STRUCTURE;
