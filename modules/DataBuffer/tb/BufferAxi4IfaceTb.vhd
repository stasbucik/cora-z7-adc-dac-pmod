----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/31/2025 02:26:07 PM
-- Design Name: 
-- Module Name: BufferAxi4IfaceTb - Behavioral
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

use std.textio.all;

entity BufferAxi4IfaceTb is
--  Port ( );
end BufferAxi4IfaceTb;

architecture Behavioral of BufferAxi4IfaceTb is

	constant CLK_PERIOD_C        : time    := 10 ns;
	constant TB_AXI_DATA_WIDTH_C : natural := 32;
	constant TB_AXI_ADDR_WIDTH_C : natural := 32;

	constant TB_NUM_ADDRESSES_C     : natural                                  := 8;
	constant TB_PACKING_C           : natural                                  := 2;
	constant TB_SAMPLE_DATA_WIDTH_C : natural                                  := 12;
	constant TB_DATA_WIDTH_C        : natural                                  := TB_PACKING_C * TB_SAMPLE_DATA_WIDTH_C;
	constant TB_BYTE_WIDTH_C        : natural                                  := TB_DATA_WIDTH_C;
	constant TB_LATENCY_C           : natural                                  := 3;
	constant TB_MEMORY_SIZE_C       : natural                                  := TB_NUM_ADDRESSES_C * TB_DATA_WIDTH_C;
	constant TB_ADDR_WIDTH_C        : natural                                  := natural(ceil(log2(real(TB_NUM_ADDRESSES_C))));
	constant TB_MAX_LENGTH_C        : natural                                  := 4;
	constant TB_LENGTH_WIDTH_C      : natural                                  := natural(ceil(log2(real(TB_MAX_LENGTH_C))));
	constant TB_AXI_ADDRESS_C       : unsigned(TB_AXI_ADDR_WIDTH_C-1 downto 0) := x"8000_0000";

	constant TB_ACTION_TIMEOUT : time := 80 ns;

	-- UUT signals
	signal clk_i        : STD_LOGIC;
	signal rst_i        : STD_LOGIC;
	signal axiReadSrc_i : Axi4ReadSource;
	signal axiReadDst_o : Axi4ReadDestination;
	signal readStart_o  : STD_LOGIC;
	signal address_o    : STD_LOGIC_VECTOR(TB_ADDR_WIDTH_C-1 downto 0);
	signal length_o     : STD_LOGIC_VECTOR(TB_LENGTH_WIDTH_C-1 downto 0);
	signal readDone_i   : STD_LOGIC;
	signal counter_i    : unsigned(TB_LENGTH_WIDTH_C downto 0);
	signal buffer_i     : TmpBufferArray(TB_MAX_LENGTH_C-1 downto 0)(TB_DATA_WIDTH_C-1 downto 0);

	constant AXI_READ_SRC_INIT_C : axiReadSrc_i'subtype := (
			ARID     => (others => '0'),
			ARADDR   => (others => '0'),
			ARLEN    => (others => '0'),
			ARSIZE   => (others => '0'),
			ARBURST  => (others => '0'),
			ARLOCK   => (others => '0'),
			ARCACHE  => (others => '0'),
			ARPROT   => (others => '0'),
			ARQOS    => (others => '0'),
			ARREGION => (others => '0'),
			ARUSER   => (others => '0'),
			ARVALID  => '0',
			RREADY   => '0'
		);

	procedure waitUntil (
			signal src             : in STD_LOGIC;
			constant val           : in STD_LOGIC;
			constant error_message : in string
		) is
	begin
		if (src = val) then
			wait for CLK_PERIOD_C;
		else
			wait until src = val for TB_ACTION_TIMEOUT;
			if (src /= val) then
				report "ERROR: " & error_message;
			end if;
		end if;
	end procedure waitUntil;

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
	BufferAxi4Iface_1 : entity work.BufferAxi4Iface
		generic map (
			PACKING_G           => TB_PACKING_C,
			SAMPLE_DATA_WIDTH_G => TB_SAMPLE_DATA_WIDTH_C,
			DATA_WIDTH_G        => TB_DATA_WIDTH_C,
			MAX_LENGTH_G        => TB_MAX_LENGTH_C,
			LENGTH_WIDTH_G      => TB_LENGTH_WIDTH_C,
			ADDR_WIDTH_G        => TB_ADDR_WIDTH_C,
			AXI_ADDRESS_G       => TB_AXI_ADDRESS_C
		)
		port map (
			clk_i        => clk_i,
			rst_i        => rst_i,
			axiReadSrc_i => axiReadSrc_i,
			axiReadDst_o => axiReadDst_o,
			readStart_o  => readStart_o,
			address_o    => address_o,
			length_o     => length_o,
			readDone_i   => readDone_i,
			counter_i    => counter_i,
			buffer_i     => buffer_i
		);

	BramBufferReader_1 : entity work.BramBufferReader
		generic map (
			MARK_DEBUG_G        => "false",
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
			readStart_i    => readStart_o,
			address_i      => address_o,
			length_i       => length_o,
			readDone_o     => readDone_i,
			counter_o      => counter_i,
			buffer_o       => buffer_i,
			readingFrom_i  => 0
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
		axiReadSrc_i <= AXI_READ_SRC_INIT_C;

		wait for CLK_PERIOD_C*3;
		rst_i <= '0';
		------------------------------------------------------------------------
		-- reset done
		------------------------------------------------------------------------
		WriteDataToBRAM((x"ba5ad0", x"badb17", x"baaaad", x"b007ed", x"f00f00", x"add1c7", x"0bebec", x"d05edd"), bramWriteSrc0);
		WriteDataToBRAM((x"ba5ad0", x"badb17", x"baaaad", x"b007ed", x"f00f00", x"add1c7", x"0bebec", x"d05edd"), bramWriteSrc1);
		wait for CLK_PERIOD_C*5;



		-- axi test error
		axiReadSrc_i.araddr  <= STD_LOGIC_VECTOR(TB_AXI_ADDRESS_C + to_unsigned(0, axiReadSrc_i.araddr'length));
		axiReadSrc_i.arlen   <= STD_LOGIC_VECTOR(to_unsigned(6-1, axiReadSrc_i.arlen'length));
		axiReadSrc_i.arsize  <= "011";
		axiReadSrc_i.arburst <= "01";
		axiReadSrc_i.arvalid <= '1';
		axiReadSrc_i.rready  <= '1';

		waitUntil(axiReadDst_o.arready, '1', "arready not 1.");
		axiReadSrc_i.arvalid <= '0';
		waitUntil(axiReadDst_o.rlast, '1', "rlast not 1.");
		waitUntil(axiReadDst_o.rlast, '0', "rlast not 0.");

		wait for CLK_PERIOD_C;
		axiReadSrc_i.araddr  <= (others => '0');
		axiReadSrc_i.arlen   <= (others => '0');
		axiReadSrc_i.arsize  <= "000";
		axiReadSrc_i.arburst <= "00";
		axiReadSrc_i.arvalid <= '0';
		axiReadSrc_i.rready  <= '0';
		wait for CLK_PERIOD_C * 5;





		-- axi ready immediately, wait for data, read 1
		axiReadSrc_i.araddr  <= STD_LOGIC_VECTOR(TB_AXI_ADDRESS_C + to_unsigned(0, axiReadSrc_i.araddr'length));
		axiReadSrc_i.arlen   <= STD_LOGIC_VECTOR(to_unsigned(1-1, axiReadSrc_i.arlen'length));
		axiReadSrc_i.arsize  <= "010";
		axiReadSrc_i.arburst <= "01";
		axiReadSrc_i.arvalid <= '1';
		axiReadSrc_i.rready  <= '1';

		waitUntil(axiReadDst_o.arready, '1', "arready not 1.");
		axiReadSrc_i.arvalid <= '0';
		waitUntil(readDone_i, '1', "readDone_i not 1.");
		waitUntil(axiReadDst_o.rlast, '1', "rlast not 1.");
		waitUntil(axiReadDst_o.rlast, '0', "rlast not 0.");

		wait for CLK_PERIOD_C;
		axiReadSrc_i.araddr  <= (others => '0');
		axiReadSrc_i.arlen   <= (others => '0');
		axiReadSrc_i.arsize  <= "000";
		axiReadSrc_i.arburst <= "00";
		axiReadSrc_i.arvalid <= '0';
		axiReadSrc_i.rready  <= '0';
		wait for CLK_PERIOD_C * 5;






		-- axi not ready immediately, wait for data, read 1
		axiReadSrc_i.araddr  <= STD_LOGIC_VECTOR(TB_AXI_ADDRESS_C + to_unsigned(0, axiReadSrc_i.araddr'length));
		axiReadSrc_i.arlen   <= STD_LOGIC_VECTOR(to_unsigned(1-1, axiReadSrc_i.arlen'length));
		axiReadSrc_i.arsize  <= "010";
		axiReadSrc_i.arburst <= "01";
		axiReadSrc_i.arvalid <= '1';

		waitUntil(axiReadDst_o.arready, '1', "arready not 1.");
		axiReadSrc_i.arvalid <= '0';
		waitUntil(readDone_i, '1', "readDone_i not 1.");
		waitUntil(axiReadDst_o.rlast, '1', "rlast not 1.");
		wait for CLK_PERIOD_C*5;
		axiReadSrc_i.rready <= '1';
		waitUntil(axiReadDst_o.rlast, '0', "rlast not 0.");

		wait for CLK_PERIOD_C;
		axiReadSrc_i.araddr  <= (others => '0');
		axiReadSrc_i.arlen   <= (others => '0');
		axiReadSrc_i.arsize  <= "000";
		axiReadSrc_i.arburst <= "00";
		axiReadSrc_i.arvalid <= '0';
		axiReadSrc_i.rready  <= '0';
		wait for CLK_PERIOD_C * 5;





		-- axi ready immediately, wait for data, read 2
		axiReadSrc_i.araddr  <= STD_LOGIC_VECTOR(TB_AXI_ADDRESS_C + to_unsigned(4*1, axiReadSrc_i.araddr'length));
		axiReadSrc_i.arlen   <= STD_LOGIC_VECTOR(to_unsigned(2-1, axiReadSrc_i.arlen'length));
		axiReadSrc_i.arsize  <= "010";
		axiReadSrc_i.arburst <= "01";
		axiReadSrc_i.arvalid <= '1';
		axiReadSrc_i.rready  <= '1';

		waitUntil(axiReadDst_o.arready, '1', "arready not 1.");
		axiReadSrc_i.arvalid <= '0';
		waitUntil(readDone_i, '1', "readDone_i not 1.");
		waitUntil(axiReadDst_o.rlast, '1', "rlast not 1.");
		waitUntil(axiReadDst_o.rlast, '0', "rlast not 0.");

		wait for CLK_PERIOD_C;
		axiReadSrc_i.araddr  <= (others => '0');
		axiReadSrc_i.arlen   <= (others => '0');
		axiReadSrc_i.arsize  <= "000";
		axiReadSrc_i.arburst <= "00";
		axiReadSrc_i.arvalid <= '0';
		axiReadSrc_i.rready  <= '0';
		wait for CLK_PERIOD_C * 5;





		-- axi ready immediately, wait for data, read 3
		axiReadSrc_i.araddr  <= STD_LOGIC_VECTOR(TB_AXI_ADDRESS_C + to_unsigned(4*3, axiReadSrc_i.araddr'length));
		axiReadSrc_i.arlen   <= STD_LOGIC_VECTOR(to_unsigned(3-1, axiReadSrc_i.arlen'length));
		axiReadSrc_i.arsize  <= "010";
		axiReadSrc_i.arburst <= "01";
		axiReadSrc_i.arvalid <= '1';
		axiReadSrc_i.rready  <= '1';

		waitUntil(axiReadDst_o.arready, '1', "arready not 1.");
		axiReadSrc_i.arvalid <= '0';
		waitUntil(readDone_i, '1', "readDone_i not 1.");
		waitUntil(axiReadDst_o.rlast, '1', "rlast not 1.");
		waitUntil(axiReadDst_o.rlast, '0', "rlast not 0.");

		wait for CLK_PERIOD_C;
		axiReadSrc_i.araddr  <= (others => '0');
		axiReadSrc_i.arlen   <= (others => '0');
		axiReadSrc_i.arsize  <= "000";
		axiReadSrc_i.arburst <= "00";
		axiReadSrc_i.arvalid <= '0';
		axiReadSrc_i.rready  <= '0';
		wait for CLK_PERIOD_C * 5;






		-- axi ready immediately, wait for data, read 4
		axiReadSrc_i.araddr  <= STD_LOGIC_VECTOR(TB_AXI_ADDRESS_C + to_unsigned(0, axiReadSrc_i.araddr'length));
		axiReadSrc_i.arlen   <= STD_LOGIC_VECTOR(to_unsigned(4-1, axiReadSrc_i.arlen'length));
		axiReadSrc_i.arsize  <= "010";
		axiReadSrc_i.arburst <= "01";
		axiReadSrc_i.arvalid <= '1';
		axiReadSrc_i.rready  <= '1';

		waitUntil(axiReadDst_o.arready, '1', "arready not 1.");
		axiReadSrc_i.arvalid <= '0';
		waitUntil(readDone_i, '1', "readDone_i not 1.");
		waitUntil(axiReadDst_o.rlast, '1', "rlast not 1.");
		waitUntil(axiReadDst_o.rlast, '0', "rlast not 0.");

		wait for CLK_PERIOD_C;
		axiReadSrc_i.araddr  <= (others => '0');
		axiReadSrc_i.arlen   <= (others => '0');
		axiReadSrc_i.arsize  <= "000";
		axiReadSrc_i.arburst <= "00";
		axiReadSrc_i.arvalid <= '0';
		axiReadSrc_i.rready  <= '0';
		wait for CLK_PERIOD_C * 5;






		-- axi ready immediately, wait for data, read 5
		axiReadSrc_i.araddr  <= STD_LOGIC_VECTOR(TB_AXI_ADDRESS_C + to_unsigned(0, axiReadSrc_i.araddr'length));
		axiReadSrc_i.arlen   <= STD_LOGIC_VECTOR(to_unsigned(5-1, axiReadSrc_i.arlen'length));
		axiReadSrc_i.arsize  <= "010";
		axiReadSrc_i.arburst <= "01";
		axiReadSrc_i.arvalid <= '1';
		axiReadSrc_i.rready  <= '1';

		waitUntil(axiReadDst_o.arready, '1', "arready not 1.");
		axiReadSrc_i.arvalid <= '0';
		waitUntil(readDone_i, '1', "readDone_i not 1.");
		waitUntil(axiReadDst_o.rlast, '1', "rlast not 1.");
		waitUntil(axiReadDst_o.rlast, '0', "rlast not 0.");

		wait for CLK_PERIOD_C;
		axiReadSrc_i.araddr  <= (others => '0');
		axiReadSrc_i.arlen   <= (others => '0');
		axiReadSrc_i.arsize  <= "000";
		axiReadSrc_i.arburst <= "00";
		axiReadSrc_i.arvalid <= '0';
		axiReadSrc_i.rready  <= '0';
		wait for CLK_PERIOD_C * 5;
		finish;

	end process stimulus;

end Behavioral;
