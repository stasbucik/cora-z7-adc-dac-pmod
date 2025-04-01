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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

use IEEE.math_real."ceil";
use IEEE.math_real."log2";

entity CoraZ707S is
	generic (
		MARK_DEBUG_G : string := "true"
	);
	Port (
		DDR_addr                : inout STD_LOGIC_VECTOR ( 14 downto 0 );
		DDR_ba                  : inout STD_LOGIC_VECTOR ( 2 downto 0 );
		DDR_cas_n               : inout STD_LOGIC;
		DDR_ck_n                : inout STD_LOGIC;
		DDR_ck_p                : inout STD_LOGIC;
		DDR_cke                 : inout STD_LOGIC;
		DDR_cs_n                : inout STD_LOGIC;
		DDR_dm                  : inout STD_LOGIC_VECTOR ( 3 downto 0 );
		DDR_dq                  : inout STD_LOGIC_VECTOR ( 31 downto 0 );
		DDR_dqs_n               : inout STD_LOGIC_VECTOR ( 3 downto 0 );
		DDR_dqs_p               : inout STD_LOGIC_VECTOR ( 3 downto 0 );
		DDR_odt                 : inout STD_LOGIC;
		DDR_ras_n               : inout STD_LOGIC;
		DDR_reset_n             : inout STD_LOGIC;
		DDR_we_n                : inout STD_LOGIC;
		FIXED_IO_ddr_vrn        : inout STD_LOGIC;
		FIXED_IO_ddr_vrp        : inout STD_LOGIC;
		FIXED_IO_mio            : inout STD_LOGIC_VECTOR ( 53 downto 0 );
		FIXED_IO_ps_clk         : inout STD_LOGIC;
		FIXED_IO_ps_porb        : inout STD_LOGIC;
		FIXED_IO_ps_srstb       : inout STD_LOGIC;
		Shield_I2C_scl_io       : inout STD_LOGIC;
		Shield_I2C_sda_io       : inout STD_LOGIC;
		Shield_SPI_io0_io       : inout STD_LOGIC;
		Shield_SPI_io1_io       : inout STD_LOGIC;
		Shield_SPI_sck_io       : inout STD_LOGIC;
		Shield_SPI_ss_io        : inout STD_LOGIC;
		btns_2bits_tri_i        : in    STD_LOGIC_VECTOR ( 1 downto 0 );
		rgb_led                 : out   STD_LOGIC_VECTOR ( 5 downto 0 );
		shield_dp0_dp13_tri_io  : inout STD_LOGIC_VECTOR ( 13 downto 0 );
		shield_dp26_dp41_tri_io : inout STD_LOGIC_VECTOR ( 15 downto 0 );
		user_dio_tri_io         : inout STD_LOGIC_VECTOR ( 11 downto 0 );
		vaux0_v_n               : in    STD_LOGIC;
		vaux0_v_p               : in    STD_LOGIC;
		vaux12_v_n              : in    STD_LOGIC;
		vaux12_v_p              : in    STD_LOGIC;
		vaux13_v_n              : in    STD_LOGIC;
		vaux13_v_p              : in    STD_LOGIC;
		vaux15_v_n              : in    STD_LOGIC;
		vaux15_v_p              : in    STD_LOGIC;
		vaux1_v_n               : in    STD_LOGIC;
		vaux1_v_p               : in    STD_LOGIC;
		vaux5_v_n               : in    STD_LOGIC;
		vaux5_v_p               : in    STD_LOGIC;
		vaux6_v_n               : in    STD_LOGIC;
		vaux6_v_p               : in    STD_LOGIC;
		vaux8_v_n               : in    STD_LOGIC;
		vaux8_v_p               : in    STD_LOGIC;
		vaux9_v_n               : in    STD_LOGIC;
		vaux9_v_p               : in    STD_LOGIC;
		vp_vn_v_n               : in    STD_LOGIC;
		vp_vn_v_p               : in    STD_LOGIC;
		ja1_p                   : out   STD_LOGIC;
		ja1_n                   : out   STD_LOGIC;
		ja2_p                   : out   STD_LOGIC;
		ja2_n                   : out   STD_LOGIC;
		ja3_p                   : out   STD_LOGIC;
		ja3_n                   : out   STD_LOGIC;
		ja4_p                   : out   STD_LOGIC;
		ja4_n                   : in    STD_LOGIC
	);
end CoraZ707S;

architecture Behavioral of CoraZ707S is

	constant MAX_VAL_C    : natural := 1024;
	constant MIN_VAL_C    : natural := 0;
	constant DATA_WIDTH_C : natural := 10;

	signal clk        : STD_LOGIC;
	signal rst        : STD_LOGIC;
	signal rstAdapter : STD_LOGIC_VECTOR(0 downto 0);

	signal data    : STD_LOGIC_VECTOR(DATA_WIDTH_C-1 downto 0);
	signal spiData : STD_LOGIC_VECTOR(15 downto 0);
	signal valid   : STD_LOGIC;
	signal ready   : STD_LOGIC;

	signal sdin : STD_LOGIC;
	signal sync : STD_LOGIC;

	-----------------------------------------------------------------------------
	attribute mark_debug          : string;
	attribute mark_debug of sdin  : signal is MARK_DEBUG_G;
	attribute mark_debug of sync  : signal is MARK_DEBUG_G;
	attribute mark_debug of data  : signal is MARK_DEBUG_G;
	attribute mark_debug of valid : signal is MARK_DEBUG_G;
	attribute mark_debug of ready : signal is MARK_DEBUG_G;

begin

	Infrastructure_wrapper : entity work.Infrastructure_wrapper
		port map (
			DDR_addr                => DDR_addr,
			DDR_ba                  => DDR_ba,
			DDR_cas_n               => DDR_cas_n,
			DDR_ck_n                => DDR_ck_n,
			DDR_ck_p                => DDR_ck_p,
			DDR_cke                 => DDR_cke,
			DDR_cs_n                => DDR_cs_n,
			DDR_dm                  => DDR_dm,
			DDR_dq                  => DDR_dq,
			DDR_dqs_n               => DDR_dqs_n,
			DDR_dqs_p               => DDR_dqs_p,
			DDR_odt                 => DDR_odt,
			DDR_ras_n               => DDR_ras_n,
			DDR_reset_n             => DDR_reset_n,
			DDR_we_n                => DDR_we_n,
			FIXED_IO_ddr_vrn        => FIXED_IO_ddr_vrn,
			FIXED_IO_ddr_vrp        => FIXED_IO_ddr_vrp,
			FIXED_IO_mio            => FIXED_IO_mio,
			FIXED_IO_ps_clk         => FIXED_IO_ps_clk,
			FIXED_IO_ps_porb        => FIXED_IO_ps_porb,
			FIXED_IO_ps_srstb       => FIXED_IO_ps_srstb,
			Shield_I2C_scl_io       => Shield_I2C_scl_io,
			Shield_I2C_sda_io       => Shield_I2C_sda_io,
			Shield_SPI_io0_io       => Shield_SPI_io0_io,
			Shield_SPI_io1_io       => Shield_SPI_io1_io,
			Shield_SPI_sck_io       => Shield_SPI_sck_io,
			Shield_SPI_ss_io        => Shield_SPI_ss_io,
			btns_2bits_tri_i        => btns_2bits_tri_i,
			peripheral_reset        => rstAdapter,
			ps_clk                  => clk,
			rgb_led                 => rgb_led,
			shield_dp0_dp13_tri_io  => shield_dp0_dp13_tri_io,
			shield_dp26_dp41_tri_io => shield_dp26_dp41_tri_io,
			user_dio_tri_io         => user_dio_tri_io,
			vaux0_v_n               => vaux0_v_n,
			vaux0_v_p               => vaux0_v_p,
			vaux12_v_n              => vaux12_v_n,
			vaux12_v_p              => vaux12_v_p,
			vaux13_v_n              => vaux13_v_n,
			vaux13_v_p              => vaux13_v_p,
			vaux15_v_n              => vaux15_v_n,
			vaux15_v_p              => vaux15_v_p,
			vaux1_v_n               => vaux1_v_n,
			vaux1_v_p               => vaux1_v_p,
			vaux5_v_n               => vaux5_v_n,
			vaux5_v_p               => vaux5_v_p,
			vaux6_v_n               => vaux6_v_n,
			vaux6_v_p               => vaux6_v_p,
			vaux8_v_n               => vaux8_v_n,
			vaux8_v_p               => vaux8_v_p,
			vaux9_v_n               => vaux9_v_n,
			vaux9_v_p               => vaux9_v_p,
			vp_vn_v_n               => vp_vn_v_n,
			vp_vn_v_p               => vp_vn_v_p
		);

	rst <= rstAdapter(0);

	OBUF_1 : OBUF
		generic map (
			DRIVE      => 12,
			IOSTANDARD => "DEFAULT",
			SLEW       => "SLOW")
		port map (
			O => ja1_p, -- Buffer output (connect directly to top-level port)
			I => sync   -- Buffer input
		);

	BUFG_inst : BUFG
		port map (
			O => ja1_n, -- 1-bit output: Clock output
			I => clk    -- 1-bit input: Clock input
		);

	ja2_p <= '0';
	ja2_n <= '0';
	ja3_p <= '0';

	OBUF_2 : OBUF
		generic map (
			DRIVE      => 12,
			IOSTANDARD => "DEFAULT",
			SLEW       => "SLOW")
		port map (
			O => ja3_n, -- Buffer output (connect directly to top-level port)
			I => sdin   -- Buffer input
		);

	ja4_p <= '0';

	SpiMasterAdapter_1 : entity work.SpiMasterAdapter
		generic map (
			DATA_WIDTH_G    => 16,
			N_CYCLES_IDLE_G => 1
		)
		port map (
			clk_i        => clk,
			rst_i        => rst,
			miso_i       => '0',
			mosi_o       => sdin,
			cs_o         => sync,
			writeData_i  => spiData,
			writeValid_i => valid,
			writeReady_o => ready,
			readData_o   => open,
			readValid_o  => open,
			readReady_i  => '0'
		);

	DataGenerator_1 : entity work.DataGenerator
		generic map (
			MAX_VAL_G    => MAX_VAL_C,
			MIN_VAL_G    => MIN_VAL_C,
			DATA_WIDTH_G => DATA_WIDTH_C
		)
		port map (
			clk_i   => clk,
			rst_i   => rst,
			data_o  => data,
			valid_o => valid,
			ready_i => ready
		);

	spiData <= b"00" & data & b"0000";

end Behavioral;
