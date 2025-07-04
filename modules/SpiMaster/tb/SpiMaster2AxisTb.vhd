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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
use std.env.all;
use work.SpiMaster2AxisPkg.all;
use work.Axi4Pkg.all;

entity SpiMaster2AxisTb is
--  Port ( );
end SpiMaster2AxisTb;

architecture Behavioral of SpiMaster2AxisTb is
	constant DATA_WIDTH_C     : natural := 8;
	constant AXI_DATA_WIDTH_C : natural := 16;

	constant CLK_PERIOD_C : time := 33 ns;

	signal clk_i : STD_LOGIC;
	signal rst_i : STD_LOGIC;

	signal miso_i1         : STD_LOGIC;
	signal mosi_o1         : STD_LOGIC;
	signal cs_o1           : STD_LOGIC;
	signal clk_o1          : STD_LOGIC;
	signal highz_o1        : STD_LOGIC;
	signal axisWriteSrc_i1 : Axi4StreamSource(
		tdata(AXI_DATA_WIDTH_C-1 downto 0),
		tstrb(AXI_DATA_WIDTH_C/8-1 downto 0),
		tkeep(AXI_DATA_WIDTH_C/8-1 downto 0),
		tid(1-1 downto 0),
		tdest(1-1 downto 0),
		tuser(1-1 downto 0)
	);
	signal axisWriteDst_o1 : Axi4StreamDestination;
	signal axisReadSrc_o1  : axisWriteSrc_i1'subtype;
	signal axisReadDst_i1  : Axi4StreamDestination;
	signal run_i1          : STD_LOGIC;
	signal overflow_o1     : STD_LOGIC;


	signal miso_i2         : STD_LOGIC;
	signal mosi_o2         : STD_LOGIC;
	signal cs_o2           : STD_LOGIC;
	signal clk_o2          : STD_LOGIC;
	signal highz_o2        : STD_LOGIC;
	signal axisWriteSrc_i2 : axisWriteSrc_i1'subtype;
	signal axisWriteDst_o2 : Axi4StreamDestination;
	signal axisReadSrc_o2  : axisWriteSrc_i1'subtype;
	signal axisReadDst_i2  : Axi4StreamDestination;
	signal run_i2          : STD_LOGIC;
	signal overflow_o2     : STD_LOGIC;

	constant AXI_4_STREAM_SRC_INIT_C : axisWriteSrc_i1'subtype := (
			TVALID  => '0',
			TDATA   => (others => '0'),
			TSTRB   => (others => '1'),
			TKEEP   => (others => '1'),
			TLAST   => '0',
			TID     => (others => '0'),
			TDEST   => (others => '0'),
			TUSER   => (others => '0'),
			TWAKEUP => '0'
		);

	constant AXI_4_STREAM_DST_INIT_C : Axi4StreamDestination := (
			TREADY => '0'
		);
begin

	clock : process
	begin
		clk_i <= '0';
		wait for CLK_PERIOD_C/2;
		clk_i <= '1';
		wait for CLK_PERIOD_C/2;
	end process;


	SpiMasterAdapter_1 : entity work.SpiMaster2Axis
		generic map (
			SPI_CPOL_G      => SPI_CPOL_1,
			SPI_CPHA_G      => SPI_CPHA_0,
			DATA_WIDTH_G    => DATA_WIDTH_C,
			N_CYCLES_IDLE_G => 1
		)
		port map (
			clk_i          => clk_i,
			rst_i          => rst_i,
			miso_i         => miso_i1,
			mosi_o         => mosi_o1,
			cs_o           => cs_o1,
			clk_o          => clk_o1,
			highz_o        => highz_o1,
			axisWriteSrc_i => axisWriteSrc_i1,
			axisWriteDst_o => axisWriteDst_o1,
			axisReadSrc_o  => axisReadSrc_o1,
			axisReadDst_i  => axisReadDst_i1,
			run_i          => run_i1,
			overflow_o     => overflow_o1
		);

	SpiMasterAdapter_2 : entity work.SpiMaster2Axis
		generic map (
			SPI_CPOL_G      => SPI_CPOL_1,
			SPI_CPHA_G      => SPI_CPHA_1,
			DATA_WIDTH_G    => DATA_WIDTH_C,
			N_CYCLES_IDLE_G => 1
		)
		port map (
			clk_i          => clk_i,
			rst_i          => rst_i,
			miso_i         => miso_i2,
			mosi_o         => mosi_o2,
			cs_o           => cs_o2,
			clk_o          => clk_o2,
			highz_o        => highz_o2,
			axisWriteSrc_i => axisWriteSrc_i2,
			axisWriteDst_o => axisWriteDst_o2,
			axisReadSrc_o  => axisReadSrc_o2,
			axisReadDst_i  => axisReadDst_i2,
			run_i          => run_i2,
			overflow_o     => overflow_o2
		);
	miso_i1 <= mosi_o1;
	miso_i2 <= mosi_o2;

	stimulus1 : process
	begin
		rst_i <= '1';
		-- initialize signals

		--miso_i         <= '0';
		axisWriteSrc_i1 <= AXI_4_STREAM_SRC_INIT_C;
		axisReadDst_i1  <= AXI_4_STREAM_DST_INIT_C;
		run_i1          <= '0';

		wait for CLK_PERIOD_C*3.5;


		rst_i <= '0';
		------------------------------------------------------------------------
		-- reset
		------------------------------------------------------------------------

		axisWriteSrc_i1.tdata  <= STD_LOGIC_VECTOR(to_unsigned(42, AXI_DATA_WIDTH_C));
		axisWriteSrc_i1.tvalid <= '1';
		wait for CLK_PERIOD_C*5;
		run_i1 <= '1';

		for i in 0 to 1030 loop
			if i < 4 then
				axisReadDst_i1.tready <= '0';
			else
				axisReadDst_i1.tready <= '1';
			end if;
			if i < 8 and i > 6 then
				run_i1 <= '0';
				wait for CLK_PERIOD_C;
				axisWriteSrc_i1.tdata  <= STD_LOGIC_VECTOR(to_unsigned(i, AXI_DATA_WIDTH_C));
				axisWriteSrc_i1.tvalid <= '1';
				wait for CLK_PERIOD_C*40;
			else
				run_i1 <= '1';
				wait for CLK_PERIOD_C;
				axisWriteSrc_i1.tdata  <= STD_LOGIC_VECTOR(to_unsigned(i, AXI_DATA_WIDTH_C));
				axisWriteSrc_i1.tvalid <= '1';

				if (axisWriteDst_o1.tready = '1') then
					wait for CLK_PERIOD_C;
				else
					wait until axisWriteDst_o1.tready = '1';
					wait for CLK_PERIOD_C;
				end if;
				axisWriteSrc_i1.tvalid <= '0';
			end if;
		end loop;

		wait;

	end process stimulus1;

	stimulus2 : process
	begin
		-- initialize signals

		--miso_i         <= '0';
		axisWriteSrc_i2 <= AXI_4_STREAM_SRC_INIT_C;
		axisReadDst_i2  <= AXI_4_STREAM_DST_INIT_C;
		run_i2          <= '0';
		wait for CLK_PERIOD_C*3.5;


		------------------------------------------------------------------------
		-- reset
		------------------------------------------------------------------------

		axisWriteSrc_i2.tdata  <= STD_LOGIC_VECTOR(to_unsigned(42, AXI_DATA_WIDTH_C));
		axisWriteSrc_i2.tvalid <= '1';
		wait for CLK_PERIOD_C*5;
		run_i2 <= '1';

		for i in 0 to 1030 loop
			if i < 4 then
				axisReadDst_i2.tready <= '0';
			else
				axisReadDst_i2.tready <= '1';
			end if;
			if i < 8 and i > 6 then
				run_i2 <= '0';
				wait for CLK_PERIOD_C;
				axisWriteSrc_i2.tdata  <= STD_LOGIC_VECTOR(to_unsigned(i, AXI_DATA_WIDTH_C));
				axisWriteSrc_i2.tvalid <= '1';
				wait for CLK_PERIOD_C*40;
			else
				run_i2 <= '1';
				wait for CLK_PERIOD_C;
				axisWriteSrc_i2.tdata  <= STD_LOGIC_VECTOR(to_unsigned(i, AXI_DATA_WIDTH_C));
				axisWriteSrc_i2.tvalid <= '1';

				if (axisWriteDst_o2.tready = '1') then
					wait for CLK_PERIOD_C;
				else
					wait until axisWriteDst_o2.tready = '1';
					wait for CLK_PERIOD_C;
				end if;
				axisWriteSrc_i2.tvalid <= '0';
			end if;
		end loop;

		wait for CLK_PERIOD_C*5;
		finish;

	end process stimulus2;

end Behavioral;
