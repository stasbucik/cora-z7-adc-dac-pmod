----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/31/2025 02:26:07 PM
-- Design Name: 
-- Module Name: DataBufferTb - Behavioral
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

entity DataBufferTb is
--  Port ( );
end DataBufferTb;

architecture Behavioral of DataBufferTb is

	constant CLK_PERIOD_C         : time    := 10 ns;
	constant TB_AXI_DATA_WIDTH_C  : natural := 32;
	constant TB_AXIS_DATA_WIDTH_C : natural := 16;
	constant TB_AXI_ADDR_WIDTH_C  : natural := 32;

	constant TB_NUM_ADDRESSES_C     : natural                                  := 16;
	constant TB_PACKING_C           : natural                                  := 2;
	constant TB_SAMPLE_DATA_WIDTH_C : natural                                  := 12;
	constant TB_DATA_WIDTH_C        : natural                                  := TB_PACKING_C * TB_SAMPLE_DATA_WIDTH_C;
	constant TB_BYTE_WIDTH_C        : natural                                  := TB_DATA_WIDTH_C;
	constant TB_LATENCY_C           : natural                                  := 1;
	constant TB_MEMORY_SIZE_C       : natural                                  := TB_NUM_ADDRESSES_C * TB_DATA_WIDTH_C;
	constant TB_ADDR_WIDTH_C        : natural                                  := natural(ceil(log2(real(TB_NUM_ADDRESSES_C))));
	constant TB_MAX_LENGTH_C        : natural                                  := 8;
	constant TB_LENGTH_WIDTH_C      : natural                                  := natural(ceil(log2(real(TB_MAX_LENGTH_C))));
	constant TB_AXI_ADDRESS_C       : unsigned(TB_AXI_ADDR_WIDTH_C-1 downto 0) := x"8000_0000";

	-- UUT signals
	signal clk_i          : STD_LOGIC;
	signal rst_i          : STD_LOGIC;
	signal axisWriteSrc_i : Axi4StreamSource(
		tdata(TB_AXIS_DATA_WIDTH_C-1 downto 0),
		tstrb(TB_AXIS_DATA_WIDTH_C/8-1 downto 0),
		tkeep(TB_AXIS_DATA_WIDTH_C/8-1 downto 0),
		tid(1-1 downto 0),
		tdest(1-1 downto 0),
		tuser(1-1 downto 0)
	);
	signal axisWriteDst_o   : Axi4StreamDestination;
	signal axiSrc_i         : Axi4Source;
	signal axiDst_o         : Axi4Destination;
	signal clear_i          : STD_LOGIC;
	signal interrupt_o      : STD_LOGIC;
	signal overwrite_o      : STD_LOGIC;
	signal clearOverwrite_o : STD_LOGIC;

	procedure waitUntil (
			signal src             : in STD_LOGIC;
			constant val           : in STD_LOGIC;
			constant error_message : in string;
			constant timeout       : in time
		) is
	begin
		if (src = val) then
			wait for CLK_PERIOD_C;
		else
			wait until src = val for timeout;
			if (src /= val) then
				report "ERROR: " & error_message;
			end if;
			wait for CLK_PERIOD_C;
		end if;
	end procedure waitUntil;

	procedure writeDataToAxis (
			signal axisSrc : out Axi4StreamSource;
			signal axisDst : in  Axi4StreamDestination;
			constant data  : in  axisSrc.tdata'subtype
		) is
	begin
		axisSrc.tdata  <= data;
		axisSrc.tvalid <= '1';
		waitUntil(axisDst.tready, '1', "tready not 1", CLK_PERIOD_C*10);

		axisSrc.tvalid <= '0';
		axisSrc.tdata  <= (others => '0');
	end procedure writeDataToAxis;

	constant AXI_BURST_SIZE_4_BYTES_C : STD_LOGIC_VECTOR(2 downto 0) := "010";
	constant AXI_BURST_TYPE_INCR_C    : STD_LOGIC_VECTOR(1 downto 0) := "01";

	type Axi4ReadResult is array (0 to TB_MAX_LENGTH_C-1) of STD_LOGIC_VECTOR(TB_AXI_DATA_WIDTH_C-1 downto 0);
	signal testData : Axi4ReadResult;

	procedure readDataFromAxi (
			signal axiSrc    : out Axi4Source;
			signal axiDst    : in  Axi4Destination;
			constant address : in  axiSrc.rd.araddr'subtype;
			signal data      : out Axi4ReadResult
		) is
	begin
		axiSrc.rd.araddr  <= address;
		axiSrc.rd.arlen   <= STD_LOGIC_VECTOR(to_unsigned(TB_MAX_LENGTH_C-1, axiSrc.rd.arlen'length));
		axiSrc.rd.arsize  <= AXI_BURST_SIZE_4_BYTES_C;
		axiSrc.rd.arburst <= AXI_BURST_SIZE_4_BYTES_C;
		axiSrc.rd.arvalid <= '1';
		waitUntil(axiDst.rd.arready, '1', "arready not 1", CLK_PERIOD_C*20);

		axiSrc.rd.araddr  <= (others => '0');
		axiSrc.rd.arlen   <= (others => '0');
		axiSrc.rd.arsize  <= (others => '0');
		axiSrc.rd.arburst <= (others => '0');
		axiSrc.rd.arvalid <= '0';

		axiSrc.rd.rready <= '1';
		for i in 0 to TB_MAX_LENGTH_C-1 loop
			waitUntil(axiDst.rd.rvalid, '1', "rvalid not 1", CLK_PERIOD_C*20);
			data(i) <= axiDst.rd.rdata;
		end loop;

	end procedure readDataFromAxi;

	procedure writeAndReadOneCycle (
			signal axisSrc     : out Axi4StreamSource;
			signal axisDst     : in  Axi4StreamDestination;
			signal axiSrc      : out Axi4Source;
			signal axiDst      : in  Axi4Destination;
			signal data        : out Axi4ReadResult;
			signal interrupt   : in  STD_LOGIC;
			constant startData : in  natural
		) is
	begin
		for i in startData to startData + TB_PACKING_C*TB_NUM_ADDRESSES_C-1 loop
			writeDataToAxis(axisSrc, axisDst, STD_LOGIC_VECTOR(to_unsigned(i, axisSrc.tdata'length)));
		end loop;

		waitUntil(interrupt, '1', "interrupt not triggered", CLK_PERIOD_C*20);

		for i in 0 to TB_NUM_ADDRESSES_C/TB_MAX_LENGTH_C-1 loop
			readDataFromAxi(axiSrc, axiDst, STD_LOGIC_VECTOR(TB_AXI_ADDRESS_C+i*TB_MAX_LENGTH_C*4), data);
			wait for CLK_PERIOD_C;
		end loop;
	end procedure writeAndReadOneCycle;

	constant AXI_SRC_INIT_C : Axi4Source := (
			rd       => (
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
		),
			wr       => (
			AWID     => (others => '0'),
			AWADDR   => (others => '0'),
			AWLEN    => (others => '0'),
			AWSIZE   => (others => '0'),
			AWBURST  => (others => '0'),
			AWLOCK   => (others => '0'),
			AWCACHE  => (others => '0'),
			AWPROT   => (others => '0'),
			AWQOS    => (others => '0'),
			AWREGION => (others => '0'),
			AWUSER   => (others => '0'),
			AWVALID  => '0',
			WID      => (others => '0'),
			WDATA    => (others => '0'),
			WSTRB    => (others => '0'),
			WLAST    => '0',
			WUSER    => (others => '0'),
			WVALID   => '0',
			BREADY   => '0'
		)
		);

	constant AXI_4_STREAM_SRC_INIT_C : axisWriteSrc_i'subtype := (
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

begin

	clock : process
	begin
		clk_i <= '1';
		wait for CLK_PERIOD_C/2;
		clk_i <= '0';
		wait for CLK_PERIOD_C/2;
	end process;

	-- UUT
	u_DataBuffer : entity work.DataBuffer
		generic map (
			MARK_DEBUG_G        => "false",
			NUM_ADDRESSES_G     => TB_NUM_ADDRESSES_C,
			PACKING_G           => TB_PACKING_C,
			SAMPLE_DATA_WIDTH_G => TB_SAMPLE_DATA_WIDTH_C,
			DATA_WIDTH_G        => TB_DATA_WIDTH_C,
			BYTE_WIDTH_G        => TB_BYTE_WIDTH_C,
			LATENCY_G           => TB_LATENCY_C,
			MEMORY_SIZE_G       => TB_MEMORY_SIZE_C,
			ADDR_WIDTH_G        => TB_ADDR_WIDTH_C,
			MAX_LENGTH_G        => TB_MAX_LENGTH_C,
			LENGTH_WIDTH_G      => TB_LENGTH_WIDTH_C,
			AXI_ADDRESS_G       => TB_AXI_ADDRESS_C
		)
		port map (
			clk_i            => clk_i,
			rst_i            => rst_i,
			axisWriteSrc_i   => axisWriteSrc_i,
			axisWriteDst_o   => axisWriteDst_o,
			axiSrc_i         => axiSrc_i,
			axiDst_o         => axiDst_o,
			clear_i          => clear_i,
			interrupt_o      => interrupt_o,
			overwrite_o      => overwrite_o,
			clearOverwrite_o => clearOverwrite_o
		);

	stimulus : process
	begin
		rst_i <= '1';
		-- initialize signals
		axisWriteSrc_i <= AXI_4_STREAM_SRC_INIT_C;
		axiSrc_i       <= AXI_SRC_INIT_C;
		clear_i        <= '0';

		wait for CLK_PERIOD_C*3;
		rst_i <= '0';
		------------------------------------------------------------------------
		-- reset done
		------------------------------------------------------------------------
		for i in 0 to 2 loop
			writeAndReadOneCycle(axisWriteSrc_i, axisWriteDst_o, axiSrc_i, axiDst_o, testData, interrupt_o, i*TB_PACKING_C*TB_NUM_ADDRESSES_C);
		end loop;


		clear_i <= '1';
		wait for CLK_PERIOD_C;
		clear_i <= '0';
		wait for CLK_PERIOD_C;

		for i in 0 to 2 loop
			writeAndReadOneCycle(axisWriteSrc_i, axisWriteDst_o, axiSrc_i, axiDst_o, testData, interrupt_o, (i + 3)*TB_PACKING_C*TB_NUM_ADDRESSES_C);
		end loop;

		finish;

	end process stimulus;

end Behavioral;
