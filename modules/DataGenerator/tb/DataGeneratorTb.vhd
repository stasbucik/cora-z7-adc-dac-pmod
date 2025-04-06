----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/31/2025 02:26:07 PM
-- Design Name: 
-- Module Name: SpiMasterAdapterTb - Behavioral
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
--library UNISIM;
--use UNISIM.VComponents.all;
use work.Axi4Pkg.all;

entity DataGeneratorTb is
--  Port ( );
end DataGeneratorTb;

architecture Behavioral of DataGeneratorTb is
	constant MAX_VAL_C : natural := 1024;
	constant MIN_VAL_C : natural := 0;


	constant AXI_DATA_WIDTH_C : natural := 16;

	constant CLK_PERIOD_C : time := 33 ns;

	-- UUT signals
	signal clk_i     : STD_LOGIC;
	signal rst_i     : STD_LOGIC;
	signal axisSrc_o : Axi4StreamSource(
		TDATA(AXI_DATA_WIDTH_C-1 downto 0),
		TSTRB(AXI_DATA_WIDTH_C/8-1 downto 0),
		TKEEP(AXI_DATA_WIDTH_C/8-1 downto 0),
		TID(1-1 downto 0),
		TDEST(1-1 downto 0)
	);
	signal axisDst_i : Axi4StreamDestination;
begin

	clock : process
	begin
		clk_i <= '0';
		wait for CLK_PERIOD_C/2;
		clk_i <= '1';
		wait for CLK_PERIOD_C/2;
	end process;

	-- UUT
	DataGenerator_1 : entity work.DataGenerator
		generic map (
			MAX_VAL_G => MAX_VAL_C,
			MIN_VAL_G => MIN_VAL_C
		)
		port map (
			clk_i     => clk_i,
			rst_i     => rst_i,
			axisSrc_o => axisSrc_o,
			axisDst_i => axisDst_i
		);

	stimulus : process
	begin
		rst_i <= '1';
		-- initialize signals

		axisDst_i.tready <= '0';

		wait for CLK_PERIOD_C*3;


		rst_i <= '0';
		------------------------------------------------------------------------
		-- reset done
		------------------------------------------------------------------------

		-- stimulus
		for i in 0 to 2048 loop
			wait for CLK_PERIOD_C*4;
			axisDst_i.tready <= '1';
			if (axisSrc_o.tvalid = '1') then
				wait for CLK_PERIOD_C;
			else
				wait until axisSrc_o.tvalid = '1';
			end if;

			axisDst_i.tready <= '0' ;
		end loop ;

		wait;

	end process stimulus;

end Behavioral;

