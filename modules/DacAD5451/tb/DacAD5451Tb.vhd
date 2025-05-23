----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Stas Bucik
-- 
-- Create Date: 03/31/2025 02:26:07 PM
-- Design Name: 
-- Module Name: DacAD5451Tb - Behavioral
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
use std.env.all;
use work.SpiMaster2AxisPkg.all;
use work.DacAD5451Pkg.all;
use work.Axi4Pkg.all;

entity DacAD5451Tb is
--  Port ( );
end DacAD5451Tb;

architecture Behavioral of DacAD5451Tb is

	constant CLK_PERIOD1_C    : time    := 15.625 ns;
	constant CLK_PERIOD2_C    : time    := 8 ns;
	constant AXI_DATA_WIDTH_C : natural := 16;

	-- UUT signals
	signal clk_i          : STD_LOGIC;
	signal spiClk_i       : STD_LOGIC;
	signal rst_i          : STD_LOGIC;
	signal sdin_o         : STD_LOGIC;
	signal sync_o         : STD_LOGIC;
	signal sclk_o         : STD_LOGIC;
	signal highz_o        : STD_LOGIC;
	signal axisWriteSrc_i : AD5451Axi4StreamSource(
		tid(1-1 downto 0),
		tdest(1-1 downto 0),
		tuser(1-1 downto 0)
	);
	signal axisWriteDst_o : Axi4StreamDestination;
	signal run_i          : STD_LOGIC;
	signal clear_i        : STD_LOGIC;



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
	u_DacAD5451 : entity work.DacAD5451
		generic map (
			MARK_DEBUG_G => "false",
			SYNC_STAGE_G => true
		)
		port map (
			clk_i          => clk_i,
			spiClk_i       => spiClk_i,
			rst_i          => rst_i,
			sdin_o         => sdin_o,
			sync_o         => sync_o,
			sclk_o         => sclk_o,
			highz_o        => highz_o,
			axisWriteSrc_i => axisWriteSrc_i,
			axisWriteDst_o => axisWriteDst_o,
			run_i          => run_i,
			clear_i        => clear_i
		);

	u_DataGenerator : entity work.DataGenerator
		generic map (
			MAX_VAL_G => 1024,
			MIN_VAL_G => 0
		)
		port map (
			clk_i     => clk_i,
			rst_i     => rst_i,
			axisSrc_o => axisWriteSrc_i,
			axisDst_i => axisWriteDst_o
		);

	stimulus1 : process
	begin
		rst_i <= '1';
		-- initialize signals

		wait for CLK_PERIOD2_C*3;

		rst_i <= '0';
		------------------------------------------------------------------------
		-- reset done
		------------------------------------------------------------------------
		wait for CLK_PERIOD2_C;
		-- stimulus

		wait;

	end process stimulus1;

	stimulus2 : process
	begin
		-- initialize signals
		run_i   <= '0';
		clear_i <= '0';

		wait for CLK_PERIOD2_C*3;
		------------------------------------------------------------------------
		-- reset done
		------------------------------------------------------------------------
		-- stimulus
		wait for CLK_PERIOD2_C*20;
		run_i <= '1';

		wait until axisWriteSrc_i.tdata = x"03FF";
		wait until axisWriteSrc_i.tvalid = '1' and axisWriteDst_o.tready = '1';
		wait for CLK_PERIOD2_C*20;
		finish;

	end process stimulus2;


end Behavioral;
