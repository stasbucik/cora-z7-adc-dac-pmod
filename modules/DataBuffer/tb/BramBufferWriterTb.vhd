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

use IEEE.math_real."ceil";
use IEEE.math_real."log2";

use work.BramBufferPkg.all;
use work.Axi4Pkg.all;
use work.BramPkg.all;

entity BramBufferWriterTb is
--  Port ( );
end BramBufferWriterTb;

architecture Behavioral of BramBufferWriterTb is

	constant CLK_PERIOD_C     : time    := 10 ns;
	constant CLK_PERIOD_ADC_C : time    := 15.625 ns;
	constant AXI_DATA_WIDTH_C : natural := 16;

	constant TB_BRAM_BUFFER_NUM_ADDRESSES_C     : natural := 4;
	constant TB_BRAM_BUFFER_PACKING_C           : natural := 3;
	constant TB_BRAM_BUFFER_SAMPLE_DATA_WIDTH_C : natural := 12;
	constant TB_BRAM_BUFFER_DATA_WIDTH_C        : natural := TB_BRAM_BUFFER_PACKING_C * TB_BRAM_BUFFER_SAMPLE_DATA_WIDTH_C;
	constant TB_BRAM_BUFFER_BYTE_WIDTH_C        : natural := TB_BRAM_BUFFER_DATA_WIDTH_C;
	constant TB_BRAM_BUFFER_LATENCY_C           : natural := 3;
	constant TB_BRAM_BUFFER_MEMORY_SIZE_C       : natural := TB_BRAM_BUFFER_NUM_ADDRESSES_C * TB_BRAM_BUFFER_DATA_WIDTH_C;
	constant TB_BRAM_BUFFER_ADDR_WIDTH_C        : natural := natural(ceil(log2(real(TB_BRAM_BUFFER_NUM_ADDRESSES_C))));

	signal clk_i                : STD_LOGIC;
	signal clkAdc_i             : STD_LOGIC;
	signal rst_i                : STD_LOGIC;

	signal run_i                : STD_LOGIC;
	signal overflow_o           : STD_LOGIC;

	-- UUT signals
	signal axisBramBufferSrc : Axi4StreamSource(
		tdata(AXI_DATA_WIDTH_C-1 downto 0),
		tstrb(AXI_DATA_WIDTH_C/8-1 downto 0),
		tkeep(AXI_DATA_WIDTH_C/8-1 downto 0),
		tid(1-1 downto 0),
		tdest(1-1 downto 0),
		tuser(1-1 downto 0)
	);
	signal axisBramBufferDst : Axi4StreamDestination;
	signal bramWriteSrc0_o   : BramSource(
		we(TB_BRAM_BUFFER_DATA_WIDTH_C/TB_BRAM_BUFFER_BYTE_WIDTH_C-1 downto 0),
		addr(TB_BRAM_BUFFER_ADDR_WIDTH_C-1 downto 0),
		din(TB_BRAM_BUFFER_DATA_WIDTH_C-1 downto 0));
	signal bramWriteSrc1_o  : bramWriteSrc0_o'subtype;
	signal writingInto_o    : natural range 0 to 1;
	signal switchedBuffer_o : STD_LOGIC;
	signal clear_i          : STD_LOGIC;
	--

	signal dout_i : STD_LOGIC;
	signal cs_o   : STD_LOGIC;
	signal sclk_o : STD_LOGIC;

	--
	signal counter : unsigned(11 downto 0) := x"000";

	procedure WriteDataToMISO (
			constant data : in  STD_LOGIC_VECTOR(11 downto 0);
			signal miso   : out STD_LOGIC
		) is
	begin
		wait until cs_o = '1';
		wait until cs_o = '0';
		miso <= '0';
		wait for CLK_PERIOD_ADC_C*2;
		for i in 11 downto 0 loop
			miso <= data(i);
			wait for CLK_PERIOD_ADC_C*2;
		end loop;
		miso <= '0';
		wait for CLK_PERIOD_ADC_C*2;
	end procedure WriteDataToMISO;

begin

	clock : process
	begin
		clk_i <= '0';
		wait for CLK_PERIOD_C/2;
		clk_i <= '1';
		wait for CLK_PERIOD_C/2;
	end process;

	clockAdc : process
	begin
		clkAdc_i <= '0';
		wait for CLK_PERIOD_ADC_C/2;
		clkAdc_i <= '1';
		wait for CLK_PERIOD_ADC_C/2;
	end process;

	-- UUT
	BramBufferWriter : entity work.BramBufferWriter
		generic map (
			NUM_ADDRESSES_G     => TB_BRAM_BUFFER_NUM_ADDRESSES_C,
			BYTE_WIDTH_G        => TB_BRAM_BUFFER_BYTE_WIDTH_C,
			SAMPLE_DATA_WIDTH_G => TB_BRAM_BUFFER_SAMPLE_DATA_WIDTH_C,
			PACKING_G           => TB_BRAM_BUFFER_PACKING_C,
			ADDR_WIDTH_G        => TB_BRAM_BUFFER_ADDR_WIDTH_C
		)
		port map (
			clk_i            => clk_i,
			rst_i            => rst_i,
			axisWriteSrc_i   => axisBramBufferSrc,
			axisWriteDst_o   => axisBramBufferDst,
			bramWriteSrc0_o  => bramWriteSrc0_o,
			bramWriteSrc1_o  => bramWriteSrc1_o,
			writingInto_o    => writingInto_o,
			switchedBuffer_o => switchedBuffer_o,
			clear_i          => clear_i
		);

	--------------------------------------------------------------------------------

	u_AdcMAX11105 : entity work.AdcMAX11105
		generic map (
			MARK_DEBUG_G    => "false",
			SYNC_STAGE_G    => true
		)
		port map (
			clk_i         => clk_i,
			spiClk_i      => clkAdc_i,
			rst_i         => rst_i,
			dout_i        => dout_i,
			cs_o          => cs_o,
			sclk_o        => sclk_o,
			axisReadSrc_o => axisBramBufferSrc,
			axisReadDst_i => axisBramBufferDst,
			run_i         => run_i,
			clear_i       => clear_i,
			overflow_o    => overflow_o
		);

	stimulus : process
	begin
		rst_i <= '1';
		-- initialize signals
		run_i   <= '0';
		clear_i <= '0';

		wait for CLK_PERIOD_C*3;
		rst_i <= '0';
		------------------------------------------------------------------------
		-- reset done
		------------------------------------------------------------------------
		wait for CLK_PERIOD_C*25;
		run_i <= '1';

		wait for CLK_PERIOD_C*500;
		clear_i <= '1';
		run_i   <= '0';
		wait for CLK_PERIOD_C*5;
		clear_i <= '0';
		run_i   <= '1';

		wait for CLK_PERIOD_C*2000;

		wait;

	end process stimulus;

	stimulus2 : process
	begin
		-- initialize signals
		dout_i <= '0';

		wait for CLK_PERIOD_ADC_C*3;
		------------------------------------------------------------------------
		-- reset done
		------------------------------------------------------------------------
		-- stimulus
		for i in 0 to 5000 loop
			counter <= to_unsigned(i, 12);
			WriteDataToMISO(STD_LOGIC_VECTOR(to_unsigned(i, 12)), dout_i);
		end loop;

		finish;
	end process stimulus2;

end Behavioral;
