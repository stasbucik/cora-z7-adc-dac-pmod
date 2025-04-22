----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
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
	signal axiSrc_i      : Axi4Source;
	signal axiDst_o      : Axi4Destination;
	signal writeEnable_o : STD_LOGIC;
	signal data_o        : STD_LOGIC_VECTOR(TB_WIDTH_C-1 downto 0);
	signal data_i        : STD_LOGIC_VECTOR(TB_WIDTH_C-1 downto 0);

	constant AXI_READ_INIT_C : axiSrc_i'subtype := (
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
			axiSrc_i      => axiSrc_i,
			axiDst_o      => axiDst_o,
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
		axiSrc_i <= AXI_READ_INIT_C;

		wait for CLK_PERIOD_C*3;
		rst_i <= '0';
		------------------------------------------------------------------------
		-- reset done
		------------------------------------------------------------------------
		wait for CLK_PERIOD_C*5;



		-- axi test read error
		axiSrc_i.rd.araddr  <= STD_LOGIC_VECTOR(TB_AXI_ADDRESS_C + to_unsigned(0, axiSrc_i.rd.araddr'length));
		axiSrc_i.rd.arlen   <= STD_LOGIC_VECTOR(to_unsigned(6-1, axiSrc_i.rd.arlen'length));
		axiSrc_i.rd.arsize  <= "010";
		axiSrc_i.rd.arburst <= "01";
		axiSrc_i.rd.arvalid <= '1';
		axiSrc_i.rd.rready  <= '1';

		waitUntil(axiDst_o.rd.arready, '1', "arready not 1.");
		axiSrc_i.rd.arvalid <= '0';
		waitUntil(axiDst_o.rd.rlast, '1', "rlast not 1.");
		waitUntil(axiDst_o.rd.rlast, '0', "rlast not 0.");

		wait for CLK_PERIOD_C;
		axiSrc_i.rd.araddr  <= (others => '0');
		axiSrc_i.rd.arlen   <= (others => '0');
		axiSrc_i.rd.arsize  <= "000";
		axiSrc_i.rd.arburst <= "00";
		axiSrc_i.rd.arvalid <= '0';
		axiSrc_i.rd.rready  <= '0';
		wait for CLK_PERIOD_C * 5;





		-- axi test write error
		axiSrc_i.wr.awaddr  <= STD_LOGIC_VECTOR(TB_AXI_ADDRESS_C + to_unsigned(0, axiSrc_i.wr.awaddr'length));
		axiSrc_i.wr.awlen   <= STD_LOGIC_VECTOR(to_unsigned(1-1, axiSrc_i.wr.awlen'length));
		axiSrc_i.wr.awsize  <= "001";
		axiSrc_i.wr.awburst <= "01";
		axiSrc_i.wr.awvalid <= '1';

		waitUntil(axiDst_o.wr.awready, '1', "awready not 1.");
		axiSrc_i.wr.awvalid <= '0';

		axiSrc_i.wr.wdata  <= (others => '1');
		axiSrc_i.wr.wvalid <= '1';
		axiSrc_i.wr.wlast  <= '1';
		waitUntil(axiDst_o.wr.wready, '1', "wready not 1.");
		axiSrc_i.wr.wvalid <= '0';

		waitUntil(axiDst_o.wr.bvalid, '1', "bvalid not 1.");
		waitUntil(axiDst_o.wr.bvalid, '0', "bvalid not 0.");

		wait for CLK_PERIOD_C;
		axiSrc_i.wr.awaddr  <= (others => '0');
		axiSrc_i.wr.awlen   <= (others => '0');
		axiSrc_i.wr.awsize  <= "000";
		axiSrc_i.wr.awburst <= "00";
		axiSrc_i.wr.awvalid <= '0';
		axiSrc_i.wr.wdata   <= (others => '0');
		axiSrc_i.wr.wvalid  <= '0';
		axiSrc_i.wr.wlast   <= '0';
		wait for CLK_PERIOD_C * 5;





		-- axi read ready immediately, wait for data
		axiSrc_i.rd.araddr  <= STD_LOGIC_VECTOR(TB_AXI_ADDRESS_C + to_unsigned(0, axiSrc_i.rd.araddr'length));
		axiSrc_i.rd.arlen   <= STD_LOGIC_VECTOR(to_unsigned(1-1, axiSrc_i.rd.arlen'length));
		axiSrc_i.rd.arsize  <= "010";
		axiSrc_i.rd.arburst <= "01";
		axiSrc_i.rd.arvalid <= '1';
		axiSrc_i.rd.rready  <= '1';

		waitUntil(axiDst_o.rd.arready, '1', "arready not 1.");
		axiSrc_i.rd.arvalid <= '0';
		waitUntil(axiDst_o.rd.rlast, '1', "rlast not 1.");
		waitUntil(axiDst_o.rd.rlast, '0', "rlast not 0.");

		wait for CLK_PERIOD_C;
		axiSrc_i.rd.araddr  <= (others => '0');
		axiSrc_i.rd.arlen   <= (others => '0');
		axiSrc_i.rd.arsize  <= "000";
		axiSrc_i.rd.arburst <= "00";
		axiSrc_i.rd.arvalid <= '0';
		axiSrc_i.rd.rready  <= '0';
		wait for CLK_PERIOD_C * 5;





		-- axi write ready immediately
		axiSrc_i.wr.awaddr  <= STD_LOGIC_VECTOR(TB_AXI_ADDRESS_C + to_unsigned(0, axiSrc_i.wr.awaddr'length));
		axiSrc_i.wr.awlen   <= STD_LOGIC_VECTOR(to_unsigned(1-1, axiSrc_i.wr.awlen'length));
		axiSrc_i.wr.awsize  <= "010";
		axiSrc_i.wr.awburst <= "00";
		axiSrc_i.wr.awvalid <= '1';

		waitUntil(axiDst_o.wr.awready, '1', "awready not 1.");
		axiSrc_i.wr.awvalid <= '0';

		axiSrc_i.wr.wdata  <= x"add1c700";
		axiSrc_i.wr.wvalid <= '1';
		axiSrc_i.wr.wlast  <= '1';
		waitUntil(axiDst_o.wr.wready, '1', "wready not 1.");
		axiSrc_i.wr.wvalid <= '0';

		waitUntil(axiDst_o.wr.bvalid, '1', "bvalid not 1.");
		waitUntil(axiDst_o.wr.bvalid, '0', "bvalid not 0.");

		wait for CLK_PERIOD_C;
		axiSrc_i.wr.awaddr  <= (others => '0');
		axiSrc_i.wr.awlen   <= (others => '0');
		axiSrc_i.wr.awsize  <= "000";
		axiSrc_i.wr.awburst <= "00";
		axiSrc_i.wr.awvalid <= '0';
		axiSrc_i.wr.wdata   <= (others => '0');
		axiSrc_i.wr.wvalid  <= '0';
		axiSrc_i.wr.wlast   <= '0';
		wait for CLK_PERIOD_C * 5;






		-- axi read ready immediately, wait for data
		axiSrc_i.rd.araddr  <= STD_LOGIC_VECTOR(TB_AXI_ADDRESS_C + to_unsigned(0, axiSrc_i.rd.araddr'length));
		axiSrc_i.rd.arlen   <= STD_LOGIC_VECTOR(to_unsigned(1-1, axiSrc_i.rd.arlen'length));
		axiSrc_i.rd.arsize  <= "010";
		axiSrc_i.rd.arburst <= "01";
		axiSrc_i.rd.arvalid <= '1';
		axiSrc_i.rd.rready  <= '1';

		waitUntil(axiDst_o.rd.arready, '1', "arready not 1.");
		axiSrc_i.rd.arvalid <= '0';
		waitUntil(axiDst_o.rd.rlast, '1', "rlast not 1.");
		waitUntil(axiDst_o.rd.rlast, '0', "rlast not 0.");

		wait for CLK_PERIOD_C;
		axiSrc_i.rd.araddr  <= (others => '0');
		axiSrc_i.rd.arlen   <= (others => '0');
		axiSrc_i.rd.arsize  <= "000";
		axiSrc_i.rd.arburst <= "00";
		axiSrc_i.rd.arvalid <= '0';
		axiSrc_i.rd.rready  <= '0';
		wait for CLK_PERIOD_C * 5;
		finish;

	end process stimulus;

end Behavioral;
