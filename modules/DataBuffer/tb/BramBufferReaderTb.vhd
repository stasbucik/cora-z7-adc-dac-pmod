----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/31/2025 02:26:07 PM
-- Design Name: 
-- Module Name: BramBufferReaderTb - Behavioral
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

use std.env.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use IEEE.math_real."ceil";
use IEEE.math_real."log2";

use work.BramPkg.all;
use work.BramBufferPkg.all;
use work.Axi4Pkg.all;

entity BramBufferReaderTb is
--  Port ( );
end BramBufferReaderTb;

architecture Behavioral of BramBufferReaderTb is

	constant CLK_PERIOD_C        : time    := 10 ns;

	constant TB_NUM_ADDRESSES_C     : natural := 8;
	constant TB_PACKING_C           : natural := 2;
	constant TB_SAMPLE_DATA_WIDTH_C : natural := 12;
	constant TB_DATA_WIDTH_C        : natural := TB_PACKING_C * TB_SAMPLE_DATA_WIDTH_C;
	constant TB_BYTE_WIDTH_C        : natural := TB_DATA_WIDTH_C;
	constant TB_LATENCY_C           : natural := 3;
	constant TB_MEMORY_SIZE_C       : natural := TB_NUM_ADDRESSES_C * TB_DATA_WIDTH_C;
	constant TB_ADDR_WIDTH_C        : natural := natural(ceil(log2(real(TB_NUM_ADDRESSES_C))));
	constant TB_MAX_LENGTH_C        : natural := 4;
	constant TB_LENGTH_WIDTH_C      : natural := natural(ceil(log2(real(TB_MAX_LENGTH_C))));

	signal bramWriteSrc0 : BramSource(
		we(TB_DATA_WIDTH_C/TB_BYTE_WIDTH_C-1 downto 0),
		addr(TB_ADDR_WIDTH_C-1 downto 0),
		din(TB_DATA_WIDTH_C-1 downto 0)
	);
	signal bramWriteSrc1 : BramSource(
		we(TB_DATA_WIDTH_C/TB_BYTE_WIDTH_C-1 downto 0),
		addr(TB_ADDR_WIDTH_C-1 downto 0),
		din(TB_DATA_WIDTH_C-1 downto 0)
	);

	constant testData : TmpBufferArray := (
			x"dead00",
			x"badb17",
			x"b007ed",
			x"ba0bab",
			x"baaaad",
			x"acce55",
			x"b0bca7",
			x"b055ed"
		);

	-- UUT signals
	signal clk_i          : STD_LOGIC;
	signal rst_i          : STD_LOGIC;
	signal bramReadSrc0_o : BramSource(
		we(TB_DATA_WIDTH_C/TB_BYTE_WIDTH_C-1 downto 0),
		addr(TB_ADDR_WIDTH_C-1 downto 0),
		din(TB_DATA_WIDTH_C-1 downto 0)
	);
	signal bramReadSrc1_o : bramReadSrc0_o'subtype;
	signal bramReadDst0_i : BramDestination(
		dout(TB_DATA_WIDTH_C-1 downto 0)
	);
	signal bramReadDst1_i : bramReadDst0_i'subtype;
	signal readStart_i    : STD_LOGIC;
	signal address_i      : STD_LOGIC_VECTOR(TB_ADDR_WIDTH_C-1 downto 0);
	signal length_i       : STD_LOGIC_VECTOR(TB_LENGTH_WIDTH_C-1 downto 0);
	signal readDone_o     : STD_LOGIC;
	signal counter_o      : unsigned(TB_LENGTH_WIDTH_C downto 0);
	signal buffer_o       : TmpBufferArray(TB_MAX_LENGTH_C-1 downto 0)(TB_DATA_WIDTH_C-1 downto 0);
	signal readingFrom_i  : natural range 0 to 1;

	procedure WriteDataToBRAM (
			constant data  : in  TmpBufferArray(open)(TB_DATA_WIDTH_C-1 downto 0);
			signal bramSrc : out bramWriteSrc0'subtype
		) is
	begin
		bramSrc.en <= '1';
		bramSrc.we <= (others => '1');
		for cnt in 0 to data'length - 1 loop
			bramSrc.addr <= STD_LOGIC_VECTOR(to_unsigned(cnt, bramSrc.addr'length));
			bramSrc.din  <= data(cnt);
			wait for CLK_PERIOD_C;
		end loop;
		bramSrc.en <= '0';
		bramSrc.we <= (others => '0');
	end procedure WriteDataToBRAM;

begin

	clock : process
	begin
		clk_i <= '1';
		wait for CLK_PERIOD_C/2;
		clk_i <= '0';
		wait for CLK_PERIOD_C/2;
	end process;

	-- UUT
	BramBufferReader_1 : entity work.BramBufferReader
		generic map (
			PACKING_G           => TB_PACKING_C,
			BYTE_WIDTH_G        => TB_BYTE_WIDTH_C,
			SAMPLE_DATA_WIDTH_G => TB_SAMPLE_DATA_WIDTH_C,
			LATENCY_G           => TB_LATENCY_C,
			DATA_WIDTH_G        => TB_DATA_WIDTH_C,
			MAX_LENGTH_G        => TB_MAX_LENGTH_C,
			LENGTH_WIDTH_G      => TB_LENGTH_WIDTH_C,
			ADDR_WIDTH_G        => TB_ADDR_WIDTH_C
		)
		port map (
			clk_i          => clk_i,
			rst_i          => rst_i,
			bramReadSrc0_o => bramReadSrc0_o,
			bramReadSrc1_o => bramReadSrc1_o,
			bramReadDst0_i => bramReadDst0_i,
			bramReadDst1_i => bramReadDst1_i,
			readStart_i    => readStart_i,
			address_i      => address_i,
			length_i       => length_i,
			readDone_o     => readDone_o,
			counter_o      => counter_o,
			buffer_o       => buffer_o,
			readingFrom_i  => readingFrom_i
		);

	u_BramWrapper0 : entity work.BramWrapper
		generic map (
			MEMORY_SIZE_G => TB_MEMORY_SIZE_C,
			ADDR_WIDTH_G  => TB_ADDR_WIDTH_C,
			BYTE_WIDTH_G  => TB_BYTE_WIDTH_C,
			DATA_WIDTH_G  => TB_DATA_WIDTH_C,
			LATENCY_G     => TB_LATENCY_C
		)
		port map (
			clk   => clk_i,
			rst   => rst_i,
			ena   => bramWriteSrc0.en,
			wea   => bramWriteSrc0.we,
			addra => bramWriteSrc0.addr,
			dina  => bramWriteSrc0.din,
			enb   => bramReadSrc0_o.en,
			addrb => bramReadSrc0_o.addr,
			doutb => bramReadDst0_i.dout
		);

	u_BramWrapper1 : entity work.BramWrapper
		generic map (
			MEMORY_SIZE_G => TB_MEMORY_SIZE_C,
			ADDR_WIDTH_G  => TB_ADDR_WIDTH_C,
			BYTE_WIDTH_G  => TB_BYTE_WIDTH_C,
			DATA_WIDTH_G  => TB_DATA_WIDTH_C,
			LATENCY_G     => TB_LATENCY_C
		)
		port map (
			clk   => clk_i,
			rst   => rst_i,
			ena   => bramWriteSrc1.en,
			wea   => bramWriteSrc1.we,
			addra => bramWriteSrc1.addr,
			dina  => bramWriteSrc1.din,
			enb   => bramReadSrc1_o.en,
			addrb => bramReadSrc1_o.addr,
			doutb => bramReadDst1_i.dout
		);

	stimulus : process
	begin
		rst_i <= '1';
		-- initialize signals
		readStart_i   <= '0';
		address_i     <= (others => '0');
		length_i      <= (others => '0');
		readingFrom_i <= 0;

		bramWriteSrc0.en   <= '0';
		bramWriteSrc0.we   <= (others => '0');
		bramWriteSrc0.addr <= (others => '0');
		bramWriteSrc0.din  <= (others => '0');
		bramWriteSrc1.en   <= '0';
		bramWriteSrc1.we   <= (others => '0');
		bramWriteSrc1.addr <= (others => '0');
		bramWriteSrc1.din  <= (others => '0');
		
		wait for CLK_PERIOD_C*3;

		rst_i         <= '0';
		------------------------------------------------------------------------
		-- reset done
		------------------------------------------------------------------------
		WriteDataToBRAM(testData, bramWriteSrc0);
		WriteDataToBRAM(testData, bramWriteSrc1);
		wait for CLK_PERIOD_C*5;

		readStart_i   <= '1';
		address_i     <= (others => '0');
		length_i      <= STD_LOGIC_VECTOR(to_unsigned(0, length_i'length));
		readingFrom_i <= 1;
		wait for CLK_PERIOD_C;
		readStart_i <= '0';
		wait for CLK_PERIOD_C*6;

		readStart_i   <= '1';
		address_i     <= STD_LOGIC_VECTOR(to_unsigned(1, address_i'length));
		length_i      <= STD_LOGIC_VECTOR(to_unsigned(1, length_i'length));
		readingFrom_i <= 1;
		wait for CLK_PERIOD_C;
		readStart_i <= '0';
		wait for CLK_PERIOD_C*7;

		readStart_i   <= '1';
		address_i     <= STD_LOGIC_VECTOR(to_unsigned(2, address_i'length));
		length_i      <= STD_LOGIC_VECTOR(to_unsigned(2, length_i'length));
		readingFrom_i <= 1;
		wait for CLK_PERIOD_C;
		readStart_i <= '0';
		wait for CLK_PERIOD_C*8;

		readStart_i   <= '1';
		address_i     <= STD_LOGIC_VECTOR(to_unsigned(4, address_i'length));
		length_i      <= STD_LOGIC_VECTOR(to_unsigned(3, length_i'length));
		readingFrom_i <= 1;
		wait for CLK_PERIOD_C;
		readStart_i <= '0';
		wait for CLK_PERIOD_C*9;





		readStart_i   <= '1';
		address_i     <= (others => '0');
		length_i      <= STD_LOGIC_VECTOR(to_unsigned(0, length_i'length));
		readingFrom_i <= 0;
		wait for CLK_PERIOD_C;
		readStart_i <= '0';
		wait for CLK_PERIOD_C*6;

		readStart_i   <= '1';
		address_i     <= STD_LOGIC_VECTOR(to_unsigned(1, address_i'length));
		length_i      <= STD_LOGIC_VECTOR(to_unsigned(1, length_i'length));
		readingFrom_i <= 0;
		wait for CLK_PERIOD_C;
		readStart_i <= '0';
		wait for CLK_PERIOD_C*7;

		readStart_i   <= '1';
		address_i     <= STD_LOGIC_VECTOR(to_unsigned(2, address_i'length));
		length_i      <= STD_LOGIC_VECTOR(to_unsigned(2, length_i'length));
		readingFrom_i <= 0;
		wait for CLK_PERIOD_C;
		readStart_i <= '0';
		wait for CLK_PERIOD_C*8;

		readStart_i   <= '1';
		address_i     <= STD_LOGIC_VECTOR(to_unsigned(4, address_i'length));
		length_i      <= STD_LOGIC_VECTOR(to_unsigned(3, length_i'length));
		readingFrom_i <= 0;
		wait for CLK_PERIOD_C;
		readStart_i <= '0';
		wait for CLK_PERIOD_C*9;

		finish;

	end process stimulus;

end Behavioral;
