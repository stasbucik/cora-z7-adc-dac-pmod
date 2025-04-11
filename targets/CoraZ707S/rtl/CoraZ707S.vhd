----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/31/2025 11:49:41 AM
-- Design Name: 
-- Module Name: CoraZ707S - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

use work.Axi4Pkg.all;
use work.DacAD5451Pkg.all;
use work.AdcMAX11105Pkg.all;
use work.BramBufferPkg.all;

entity CoraZ707S is
	generic (
		MARK_DEBUG_G : string := "true"
	);
	Port (
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
		Shield_I2C_scl_io : inout STD_LOGIC;
		Shield_I2C_sda_io : inout STD_LOGIC;
		Shield_SPI_io0_io : inout STD_LOGIC;
		Shield_SPI_io1_io : inout STD_LOGIC;
		Shield_SPI_sck_io : inout STD_LOGIC;
		Shield_SPI_ss_io  : inout STD_LOGIC;
		rgb_led           : out   STD_LOGIC_VECTOR ( 5 downto 0 );
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
		vp_vn_v_p         : in    STD_LOGIC;
		ja1_p             : out   STD_LOGIC;
		ja1_n             : out   STD_LOGIC;
		ja2_p             : out   STD_LOGIC;
		ja2_n             : out   STD_LOGIC;
		ja3_p             : out   STD_LOGIC;
		ja3_n             : inout STD_LOGIC;
		ja4_p             : out   STD_LOGIC;
		ja4_n             : in    STD_LOGIC
	);
end CoraZ707S;

architecture Behavioral of CoraZ707S is

	constant AXI_DATA_WIDTH_C : natural := 16;

	signal clk : STD_LOGIC;
	signal rst : STD_LOGIC;

	-- DAC signals
	signal dacSdin  : STD_LOGIC;
	signal dacSync  : STD_LOGIC;
	signal dacHighz : STD_LOGIC;
	signal dacSclk  : STD_LOGIC;

	signal axisDacSrc : AD5451Axi4StreamSource(
		tid(1-1 downto 0),
		tdest(1-1 downto 0),
		tuser(1-1 downto 0)
	);
	signal axisDacDst : Axi4StreamDestination;

	-- ADC signals
	signal adcSpiClk : STD_LOGIC;
	signal adcDout   : STD_LOGIC;
	signal adcCs     : STD_LOGIC;
	signal adcSclk   : STD_LOGIC;

	signal axisAdcSrc : MAX11105Axi4StreamSource(
		tid(1-1 downto 0),
		tdest(1-1 downto 0),
		tuser(1-1 downto 0)
	);
	signal axisAdcDst : Axi4StreamDestination;

	signal axiPsSrc : Axi4Source;
	signal axiPsDst : Axi4Destination;

	signal adcOverflow : STD_LOGIC;

	-----------------------------------------------------------------------------
	attribute mark_debug                : string;
	attribute mark_debug of dacSdin     : signal is MARK_DEBUG_G;
	attribute mark_debug of dacSync     : signal is MARK_DEBUG_G;
	attribute mark_debug of dacHighz    : signal is MARK_DEBUG_G;
	attribute mark_debug of axisDacSrc  : signal is MARK_DEBUG_G;
	attribute mark_debug of axisDacDst  : signal is MARK_DEBUG_G;
	attribute mark_debug of adcDout     : signal is MARK_DEBUG_G;
	attribute mark_debug of adcCs       : signal is MARK_DEBUG_G;
	attribute mark_debug of axisAdcSrc  : signal is MARK_DEBUG_G;
	attribute mark_debug of axisAdcDst  : signal is MARK_DEBUG_G;
	attribute mark_debug of adcOverflow : signal is MARK_DEBUG_G;
	----------------------------------------------------------------------------

	component clk_wiz_mmc_100_64
		port
		(
			clk_out1 : out std_logic;
			reset    : in  std_logic;
			locked   : out std_logic;
			clk_in1  : in  std_logic
		);
	end component;
begin

	u_InfrastructureTop : entity work.InfrastructureTop
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
			axiPsSrc          => axiPsSrc,
			axiPsDst          => axiPsDst,
			Shield_I2C_scl_io => Shield_I2C_scl_io,
			Shield_I2C_sda_io => Shield_I2C_sda_io,
			Shield_SPI_io0_io => Shield_SPI_io0_io,
			Shield_SPI_io1_io => Shield_SPI_io1_io,
			Shield_SPI_sck_io => Shield_SPI_sck_io,
			Shield_SPI_ss_io  => Shield_SPI_ss_io,
			peripheral_reset  => rst,
			ps_clk            => clk,
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


	----------------------------------------------------------------------------
	adc_clk : clk_wiz_mmc_100_64
		port map (
			clk_out1 => adcSpiClk,
			reset    => rst,
			locked   => open,
			clk_in1  => clk
		);

	----------------------------------------------------------------------------
	OBUF_DAC_SYNC : OBUF
		generic map (
			DRIVE      => 12,
			IOSTANDARD => "DEFAULT",
			SLEW       => "SLOW")
		port map (
			O => ja1_p,  -- Buffer output (connect directly to top-level port)
			I => dacSync -- Buffer input
		);

	BUFG_DAC_CLK : BUFG
		port map (
			O => ja1_n,  -- 1-bit output: Clock output
			I => dacSclk -- 1-bit input: Clock input
		);

	BUFG_ADC_CLK : BUFG
		port map (
			O => ja2_p,  -- 1-bit output: Clock output
			I => adcSclk -- 1-bit input: Clock input
		);

	OBUF_ADC_CS : OBUF
		generic map (
			DRIVE      => 12,
			IOSTANDARD => "DEFAULT",
			SLEW       => "SLOW")
		port map (
			O => ja2_n, -- Buffer output (connect directly to top-level port)
			I => adcCs  -- Buffer input
		);

	ja3_p <= '0';

	OBUFT_DAC_SDIN : OBUFT
		generic map (
			DRIVE      => 12,
			IOSTANDARD => "DEFAULT",
			SLEW       => "SLOW")
		port map (
			O => ja3_n,   -- Buffer output (connect directly to top-level port)
			I => dacSdin, -- Buffer input
			T => dacHighz -- 3-state enable input
		);

	ja4_p <= '0';

	IBUF_ADC_DOUT : IBUF
		generic map (
			IBUF_LOW_PWR => FALSE, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
			IOSTANDARD   => "LVCMOS33")
		port map (
			O => adcDout, -- Buffer output
			I => ja4_n    -- Buffer input (connect directly to top-level port)
		);
	----------------------------------------------------------------------------
	u_DacAD5451 : entity work.DacAD5451
		generic map (
			MARK_DEBUG_G    => "false",
			SYNC_STAGE_G    => false,
			N_CYCLES_IDLE_G => 2
		)
		port map (
			clk_i          => clk,
			spiClk_i       => '0',
			rst_i          => rst,
			sdin_o         => dacSdin,
			sync_o         => dacSync,
			sclk_o         => dacSclk,
			highz_o        => dacHighz,
			axisWriteSrc_i => axisDacSrc,
			axisWriteDst_o => axisDacDst,
			run_i          => '1'
		);

	u_DataGenerator : entity work.DataGenerator
		generic map (
			MAX_VAL_G => 1024,
			MIN_VAL_G => 0
		)
		port map (
			clk_i     => clk,
			rst_i     => rst,
			axisSrc_o => axisDacSrc,
			axisDst_i => axisDacDst
		);

	------------------------------------------------------------------------
	u_AdcMAX11105 : entity work.AdcMAX11105
		generic map (
			MARK_DEBUG_G    => "false",
			SYNC_STAGE_G    => true,
			N_CYCLES_IDLE_G => 0
		)
		port map (
			clk_i         => clk,
			spiClk_i      => adcSpiClk,
			rst_i         => rst,
			dout_i        => adcDout,
			cs_o          => adcCs,
			sclk_o        => adcSclk,
			axisReadSrc_o => axisAdcSrc,
			axisReadDst_i => axisAdcDst,
			run_i         => '1',
			overflow_o    => adcOverflow
		);

	rgb_led <= (0 => adcOverflow, others => '0');

	----------------------------------------------------------------------------
	u_DataBuffer : entity work.DataBuffer
		generic map (
			MARK_DEBUG_G        => "false",
			NUM_ADDRESSES_G     => BRAM_BUFFER_NUM_ADDRESSES_C,
			PACKING_G           => BRAM_BUFFER_PACKING_C,
			SAMPLE_DATA_WIDTH_G => BRAM_BUFFER_SAMPLE_DATA_WIDTH_C,
			DATA_WIDTH_G        => BRAM_BUFFER_DATA_WIDTH_C,
			BYTE_WIDTH_G        => BRAM_BUFFER_BYTE_WIDTH_C,
			LATENCY_G           => BRAM_BUFFER_LATENCY_C,
			MEMORY_SIZE_G       => BRAM_BUFFER_MEMORY_SIZE_C,
			ADDR_WIDTH_G        => BRAM_BUFFER_ADDR_WIDTH_C,
			MAX_LENGTH_G        => BRAM_BUFFER_MAX_LENGTH_C,
			LENGTH_WIDTH_G      => BRAM_BUFFER_LENGTH_WIDTH_C
		)
		port map (
			clk_i          => clk,
			rst_i          => rst,
			axisWriteSrc_i => axisAdcSrc,
			axisWriteDst_o => axisAdcDst,
			axiSrc_i   => axiPsSrc,
			axiDst_o   => axiPsDst
		);

end Behavioral;
