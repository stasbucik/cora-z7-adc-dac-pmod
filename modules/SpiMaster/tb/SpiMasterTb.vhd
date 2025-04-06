----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/31/2025 02:26:07 PM
-- Design Name: 
-- Module Name: SpiMasterTb - Behavioral
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
--library UNISIM;
--use UNISIM.VComponents.all;

use work.SpiAdapterPkg.all;
use work.Axi4Pkg.all;

entity SpiMasterTb is
--  Port ( );
end SpiMasterTb;

architecture Behavioral of SpiMasterTb is

	constant CLK_PERIOD1_C    : time    := 10 ns;
	constant CLK_PERIOD2_C    : time    := 8 ns;
	constant AXI_DATA_WIDTH_C : natural := 16;

	-- UUT signals
	signal clk_i    : STD_LOGIC;
	signal spiClk_i : STD_LOGIC;
	signal rst_i    : STD_LOGIC;

	signal miso_i  : STD_LOGIC;
	signal mosi_o  : STD_LOGIC;
	signal cs_o    : STD_LOGIC;
	signal clk_o   : STD_LOGIC;
	signal highz_o : STD_LOGIC;

	signal axisWriteSrc_i : Axi4StreamSource(
		tdata(AXI_DATA_WIDTH_C-1 downto 0),
		tstrb(AXI_DATA_WIDTH_C/8-1 downto 0),
		tkeep(AXI_DATA_WIDTH_C/8-1 downto 0),
		tid(4-1 downto 0),
		tdest(4-1 downto 0)
	);

	signal axisWriteDst_o : Axi4StreamDestination;
	signal axisReadSrc_o  : axisWriteSrc_i'subtype;
	signal axisReadDst_i  : Axi4StreamDestination;

	constant AXI_4_STREAM_SRC_INIT_C : axisWriteSrc_i'subtype := (
			TVALID  => '0',
			TDATA   => (others => '0'),
			TSTRB   => (others => '1'),
			TKEEP   => (others => '1'),
			TLAST   => '0',
			TID     => (others => '0'),
			TDEST   => (others => '0'),
			TWAKEUP => '0'
		);

	constant AXI_4_STREAM_DST_INIT_C : Axi4StreamDestination := (
			TREADY => '0'
		);
begin

	clock1 : process
	begin
		spiClk_i <= '0';
		wait for CLK_PERIOD1_C/2;
		spiClk_i <= '1';
		wait for CLK_PERIOD1_C/2;
	end process;

	clock2 : process
	begin
		clk_i <= '0';
		wait for CLK_PERIOD2_C/2;
		clk_i <= '1';
		wait for CLK_PERIOD2_C/2;
	end process;

	-- UUT
	u_SpiMaster : entity work.SpiMaster
		generic map (
			MARK_DEBUG_G    => "false",
			SPI_CPOL_G      => SPI_CPOL_0,
			SPI_CPHA_G      => SPI_CPHA_1,
			DATA_WIDTH_G    => 16,
			N_CYCLES_IDLE_G => 2
		)
		port map (
			clk_i          => clk_i,
			spiClk_i       => spiClk_i,
			rst_i          => rst_i,
			miso_i         => miso_i,
			mosi_o         => mosi_o,
			cs_o           => cs_o,
			clk_o          => clk_o,
			highz_o        => highz_o,
			axisWriteSrc_i => axisWriteSrc_i,
			axisWriteDst_o => axisWriteDst_o,
			axisReadSrc_o  => axisReadSrc_o,
			axisReadDst_i  => axisReadDst_i
		);

	u_DataGenerator : entity work.DataGenerator
		generic map (
			MAX_VAL_G => 0,
			MIN_VAL_G => 1024
		)
		port map (
			clk_i     => clk_i,
			rst_i     => rst_i,
			axisSrc_o => axisWriteSrc_i,
			axisDst_i => axisWriteDst_o
		);		

	stimulus : process
	begin
		rst_i <= '1';
		-- initialize signals

		miso_i         <= '0';
		axisReadDst_i  <= AXI_4_STREAM_DST_INIT_C;

		wait for CLK_PERIOD2_C*3;

		rst_i <= '0';
		------------------------------------------------------------------------
		-- reset done
		------------------------------------------------------------------------
		wait for CLK_PERIOD2_C;
		-- stimulus

		axisReadDst_i.tready <= '1';

		wait;

	end process stimulus;

end Behavioral;
