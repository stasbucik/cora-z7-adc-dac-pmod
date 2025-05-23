----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Stas Bucik
-- 
-- Create Date: 03/31/2025 02:26:07 PM
-- Design Name: 
-- Module Name: CtrlRegAxi4IfaceTb - Behavioral
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

entity CtrlRegAxi4IfaceTb is
--  Port ( );
end CtrlRegAxi4IfaceTb;

architecture Behavioral of CtrlRegAxi4IfaceTb is

	constant CLK_PERIOD_C        : time    := 10 ns;
	constant TB_AXI_DATA_WIDTH_C : natural := 32;
	constant TB_AXI_ADDR_WIDTH_C : natural := 32;

	constant TB_WIDTH_C       : natural                                  := 32;
	constant TB_AXI_ADDRESS_C : unsigned(TB_AXI_ADDR_WIDTH_C-1 downto 0) := x"8000_0000";

	constant TB_ACTION_TIMEOUT : time := 80 ns;

	-- UUT signals
	signal clk_i         : STD_LOGIC;
	signal rst_i         : STD_LOGIC;
	signal axiReadSrc_i  : Axi4ReadSource;
	signal axiReadDst_o  : Axi4ReadDestination;
	signal axiWriteSrc_i : Axi4WriteSource;
	signal axiWriteDst_o : Axi4WriteDestination;
	signal writeEnable_o : STD_LOGIC;
	signal data_o        : STD_LOGIC_VECTOR(TB_WIDTH_C-1 downto 0);
	signal data_i        : STD_LOGIC_VECTOR(TB_WIDTH_C-1 downto 0);

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
	constant AXI_WRITE_SRC_INIT_C : axiWriteSrc_i'subtype := (
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

begin

	clock : process
	begin
		clk_i <= '1';
		wait for CLK_PERIOD_C/2;
		clk_i <= '0';
		wait for CLK_PERIOD_C/2;
	end process;

	-- UUT
	u_CtrlRegAxi4Iface : entity work.CtrlRegAxi4Iface
		generic map (
			MARK_DEBUG_G  => "false",
			WIDTH_G       => TB_WIDTH_C,
			AXI_ADDRESS_G => TB_AXI_ADDRESS_C
		)
		port map (
			clk_i         => clk_i,
			rst_i         => rst_i,
			axiReadSrc_i  => axiReadSrc_i,
			axiReadDst_o  => axiReadDst_o,
			axiWriteSrc_i => axiWriteSrc_i,
			axiWriteDst_o => axiWriteDst_o,
			writeEnable_o => writeEnable_o,
			data_o        => data_o,
			data_i        => data_i
		);

	u_SimpleRegister : entity work.SimpleRegister
		generic map (
			WIDTH_G => TB_WIDTH_C
		)
		port map (
			clk_i       => clk_i,
			rst_i       => rst_i,
			din_i       => data_o,
			dout_o      => data_i,
			writeCtrl_i => writeEnable_o
		);

	stimulus : process
	begin
		rst_i <= '1';
		-- initialize signals
		axiReadSrc_i  <= AXI_READ_SRC_INIT_C;
		axiWriteSrc_i <= AXI_WRITE_SRC_INIT_C;

		wait for CLK_PERIOD_C*3;
		rst_i <= '0';
		------------------------------------------------------------------------
		-- reset done
		------------------------------------------------------------------------
		wait for CLK_PERIOD_C*5;



		-- axi test read error
		axiReadSrc_i.araddr  <= STD_LOGIC_VECTOR(TB_AXI_ADDRESS_C + to_unsigned(0, axiReadSrc_i.araddr'length));
		axiReadSrc_i.arlen   <= STD_LOGIC_VECTOR(to_unsigned(6-1, axiReadSrc_i.arlen'length));
		axiReadSrc_i.arsize  <= "010";
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





		-- axi test write error
		axiWriteSrc_i.awaddr  <= STD_LOGIC_VECTOR(TB_AXI_ADDRESS_C + to_unsigned(0, axiWriteSrc_i.awaddr'length));
		axiWriteSrc_i.awlen   <= STD_LOGIC_VECTOR(to_unsigned(1-1, axiWriteSrc_i.awlen'length));
		axiWriteSrc_i.awsize  <= "001";
		axiWriteSrc_i.awburst <= "01";
		axiWriteSrc_i.awvalid <= '1';

		waitUntil(axiWriteDst_o.awready, '1', "awready not 1.");
		wait for CLK_PERIOD_C;
		axiWriteSrc_i.awvalid <= '0';

		axiWriteSrc_i.wdata  <= (others => '1');
		axiWriteSrc_i.wvalid <= '1';
		axiWriteSrc_i.wlast  <= '1';
		waitUntil(axiWriteDst_o.wready, '1', "wready not 1.");
		wait for CLK_PERIOD_C;
		axiWriteSrc_i.wvalid <= '0';
		axiWriteSrc_i.bready <= '1';

		waitUntil(axiWriteDst_o.bvalid, '1', "bvalid not 1.");
		waitUntil(axiWriteDst_o.bvalid, '0', "bvalid not 0.");

		wait for CLK_PERIOD_C;
		axiWriteSrc_i.awaddr  <= (others => '0');
		axiWriteSrc_i.awlen   <= (others => '0');
		axiWriteSrc_i.awsize  <= "000";
		axiWriteSrc_i.awburst <= "00";
		axiWriteSrc_i.awvalid <= '0';
		axiWriteSrc_i.wdata   <= (others => '0');
		axiWriteSrc_i.wvalid  <= '0';
		axiWriteSrc_i.wlast   <= '0';
		axiWriteSrc_i.bready  <= '0';
		wait for CLK_PERIOD_C * 5;





		-- axi read ready immediately, wait for data
		axiReadSrc_i.araddr  <= STD_LOGIC_VECTOR(TB_AXI_ADDRESS_C + to_unsigned(0, axiReadSrc_i.araddr'length));
		axiReadSrc_i.arlen   <= STD_LOGIC_VECTOR(to_unsigned(1-1, axiReadSrc_i.arlen'length));
		axiReadSrc_i.arsize  <= "010";
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





		-- axi write ready immediately
		axiWriteSrc_i.awaddr  <= STD_LOGIC_VECTOR(TB_AXI_ADDRESS_C + to_unsigned(0, axiWriteSrc_i.awaddr'length));
		axiWriteSrc_i.awlen   <= STD_LOGIC_VECTOR(to_unsigned(1-1, axiWriteSrc_i.awlen'length));
		axiWriteSrc_i.awsize  <= "010";
		axiWriteSrc_i.awburst <= "00";
		axiWriteSrc_i.awvalid <= '1';

		waitUntil(axiWriteDst_o.awready, '1', "awready not 1.");
		wait for CLK_PERIOD_C;
		axiWriteSrc_i.awvalid <= '0';

		axiWriteSrc_i.wdata  <= x"add1c700";
		axiWriteSrc_i.wvalid <= '1';
		axiWriteSrc_i.wlast  <= '1';
		waitUntil(axiWriteDst_o.wready, '1', "wready not 1.");
		wait for CLK_PERIOD_C;
		axiWriteSrc_i.wvalid <= '0';
		axiWriteSrc_i.bready <= '1';

		waitUntil(axiWriteDst_o.bvalid, '1', "bvalid not 1.");
		waitUntil(axiWriteDst_o.bvalid, '0', "bvalid not 0.");

		wait for CLK_PERIOD_C;
		axiWriteSrc_i.awaddr  <= (others => '0');
		axiWriteSrc_i.awlen   <= (others => '0');
		axiWriteSrc_i.awsize  <= "000";
		axiWriteSrc_i.awburst <= "00";
		axiWriteSrc_i.awvalid <= '0';
		axiWriteSrc_i.wdata   <= (others => '0');
		axiWriteSrc_i.wvalid  <= '0';
		axiWriteSrc_i.wlast   <= '0';
		axiWriteSrc_i.bready  <= '0';
		wait for CLK_PERIOD_C * 5;






		-- axi read ready immediately, wait for data
		axiReadSrc_i.araddr  <= STD_LOGIC_VECTOR(TB_AXI_ADDRESS_C + to_unsigned(0, axiReadSrc_i.araddr'length));
		axiReadSrc_i.arlen   <= STD_LOGIC_VECTOR(to_unsigned(1-1, axiReadSrc_i.arlen'length));
		axiReadSrc_i.arsize  <= "010";
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






		-- axi write ready immediately
		axiWriteSrc_i.awaddr  <= STD_LOGIC_VECTOR(TB_AXI_ADDRESS_C + to_unsigned(0, axiWriteSrc_i.awaddr'length));
		axiWriteSrc_i.awlen   <= STD_LOGIC_VECTOR(to_unsigned(1-1, axiWriteSrc_i.awlen'length));
		axiWriteSrc_i.awsize  <= "010";
		axiWriteSrc_i.awburst <= "00";
		axiWriteSrc_i.awvalid <= '1';

		waitUntil(axiWriteDst_o.awready, '1', "awready not 1.");
		wait for CLK_PERIOD_C;
		axiWriteSrc_i.awvalid <= '0';

		axiWriteSrc_i.wdata  <= x"deadbeef";
		axiWriteSrc_i.wvalid <= '1';
		axiWriteSrc_i.wlast  <= '1';
		waitUntil(axiWriteDst_o.wready, '1', "wready not 1.");
		wait for CLK_PERIOD_C;
		axiWriteSrc_i.wvalid <= '0';
		axiWriteSrc_i.bready <= '1';

		waitUntil(axiWriteDst_o.bvalid, '1', "bvalid not 1.");
		waitUntil(axiWriteDst_o.bvalid, '0', "bvalid not 0.");

		wait for CLK_PERIOD_C;
		axiWriteSrc_i.awaddr  <= (others => '0');
		axiWriteSrc_i.awlen   <= (others => '0');
		axiWriteSrc_i.awsize  <= "000";
		axiWriteSrc_i.awburst <= "00";
		axiWriteSrc_i.awvalid <= '0';
		axiWriteSrc_i.wdata   <= (others => '0');
		axiWriteSrc_i.wvalid  <= '0';
		axiWriteSrc_i.wlast   <= '0';
		axiWriteSrc_i.bready  <= '0';
		wait for CLK_PERIOD_C * 5;






		-- axi read ready immediately, wait for data
		axiReadSrc_i.araddr  <= STD_LOGIC_VECTOR(TB_AXI_ADDRESS_C + to_unsigned(0, axiReadSrc_i.araddr'length));
		axiReadSrc_i.arlen   <= STD_LOGIC_VECTOR(to_unsigned(1-1, axiReadSrc_i.arlen'length));
		axiReadSrc_i.arsize  <= "010";
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
		finish;

	end process stimulus;

end Behavioral;
