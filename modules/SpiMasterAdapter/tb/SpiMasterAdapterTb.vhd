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

--use work.SpiAdapterPkg.all;

entity SpiMasterAdapterTb is
--  Port ( );
end SpiMasterAdapterTb;

architecture Behavioral of SpiMasterAdapterTb is
	constant DATA_WIDTH_C : natural := 10;

	constant CLK_PERIOD_C : time := 33 ns;

	signal clk_i        : STD_LOGIC;
	signal rst_i        : STD_LOGIC;
	signal miso_i       : STD_LOGIC;
	signal mosi_o       : STD_LOGIC;
	signal cs_o         : STD_LOGIC;
	signal writeData_i  : STD_LOGIC_VECTOR(DATA_WIDTH_C-1 downto 0);
	signal writeValid_i : STD_LOGIC;
	signal writeReady_o : STD_LOGIC;
	signal readData_o   : STD_LOGIC_VECTOR(DATA_WIDTH_C-1 downto 0);
	signal readValid_o  : STD_LOGIC;
	signal readReady_i  : STD_LOGIC;
begin

	clock : process
	begin
		clk_i <= '0';
		wait for CLK_PERIOD_C/2;
		clk_i <= '1';
		wait for CLK_PERIOD_C/2;
	end process;

	SpiMasterAdapter_1 : entity work.SpiMasterAdapter
		generic map (
			DATA_WIDTH_G    => DATA_WIDTH_C,
			N_CYCLES_IDLE_G => 1
		)
		port map (
			clk_i        => clk_i,
			rst_i        => rst_i,
			miso_i       => miso_i,
			mosi_o       => mosi_o,
			cs_o         => cs_o,
			writeData_i  => writeData_i,
			writeValid_i => writeValid_i,
			writeReady_o => writeReady_o,
			readData_o   => readData_o,
			readValid_o  => readValid_o,
			readReady_i  => readReady_i
		);

	stimulus : process
	begin
		rst_i <= '1';
		-- initialize signals

		miso_i       <= '0';
		writeData_i  <= (others => '0');
		writeValid_i <= '0';
		readReady_i  <= '0';

		wait for CLK_PERIOD_C*3;


		rst_i <= '0';
		------------------------------------------------------------------------
		-- reset
		------------------------------------------------------------------------

		for i in 0 to 1030 loop
			wait for CLK_PERIOD_C;
			writeData_i  <= b"1001100101";
			writeValid_i <= '1';

			if (writeReady_o = '1') then
				wait for CLK_PERIOD_C;
			else
				wait until writeReady_o = '1';
				wait for CLK_PERIOD_C;
			end if;
			writeValid_i <= '0';
		end loop;

		wait;

	end process stimulus;

end Behavioral;
