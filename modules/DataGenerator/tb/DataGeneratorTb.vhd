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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use std.env.all;

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
		TDEST(1-1 downto 0),
		TUSER(1-1 downto 0)
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

		wait for CLK_PERIOD_C*3.5;


		rst_i <= '0';
		------------------------------------------------------------------------
		-- reset done
		------------------------------------------------------------------------

		axisDst_i.tready <= '1';
		for i in 0 to 5 loop
			wait for CLK_PERIOD_C*4;
			if (axisSrc_o.tvalid = '1') then
				wait for CLK_PERIOD_C;
			else
				wait until axisSrc_o.tvalid = '1';
			end if;
		end loop ;
		axisDst_i.tready <= '0' ;
		wait for CLK_PERIOD_C*5;


		-- stimulus
		for i in 0 to 5 loop
			wait for CLK_PERIOD_C*4;
			axisDst_i.tready <= '1';
			if (axisSrc_o.tvalid = '1') then
				wait for CLK_PERIOD_C;
			else
				wait until axisSrc_o.tvalid = '1';
			end if;

			axisDst_i.tready <= '0' ;
		end loop ;

		finish;

	end process stimulus;

end Behavioral;

