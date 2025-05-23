----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/31/2025 02:26:07 PM
-- Design Name: 
-- Module Name: AdcMAX11105Tb - Behavioral
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
use std.env.all;
use work.SpiMaster2AxisPkg.all;
use work.AdcMAX11105Pkg.all;
use work.Axi4Pkg.all;

entity AdcMAX11105Tb is
--  Port ( );
end AdcMAX11105Tb;

architecture Behavioral of AdcMAX11105Tb is

	constant CLK_PERIOD1_C    : time    := 15.625 ns;
	constant CLK_PERIOD2_C    : time    := 8 ns;
	constant AXI_DATA_WIDTH_C : natural := 16;

	-- UUT signals
	signal clk_i         : STD_LOGIC;
	signal spiClk_i      : STD_LOGIC;
	signal rst_i         : STD_LOGIC;
	signal dout_i        : STD_LOGIC;
	signal cs_o          : STD_LOGIC;
	signal sclk_o        : STD_LOGIC;
	signal axisReadSrc_o : MAX11105Axi4StreamSource(
		tid(1-1 downto 0),
		tdest(1-1 downto 0),
		tuser(1-1 downto 0)
	);
	signal axisReadDst_i : Axi4StreamDestination;

	signal run_i      : STD_LOGIC;
	signal overflow_o : STD_LOGIC;
	signal clear_i    : STD_LOGIC;

	----------------------------------------------------------------------------
	signal counter : unsigned(11 downto 0) := x"000";

	constant AXI_4_STREAM_DST_INIT_C : Axi4StreamDestination := (
			TREADY => '0'
		);

	procedure WriteDataToMISO (
			constant data : in  STD_LOGIC_VECTOR(11 downto 0);
			signal miso   : out STD_LOGIC
		) is
	begin
		wait until cs_o = '1';
		wait until cs_o = '0';
		miso <= '0';
		wait for CLK_PERIOD1_C*2;
		for i in 11 downto 0 loop
			miso <= data(i);
			wait for CLK_PERIOD1_C*2;
		end loop;
		miso <= '0';
		wait for CLK_PERIOD1_C*2;
	end procedure WriteDataToMISO;
begin

	clock1 : process
	begin
		spiClk_i <= '0';
		wait for CLK_PERIOD1_C/2;
		spiClk_i <= '1';
		wait for CLK_PERIOD1_C/2;
	end process;

	clock2 : process
	begin
		clk_i <= '0';
		wait for CLK_PERIOD2_C/2;
		clk_i <= '1';
		wait for CLK_PERIOD2_C/2;
	end process;

	-- UUT
	u_AdcMAX11105 : entity work.AdcMAX11105
		generic map (
			MARK_DEBUG_G => "false",
			SYNC_STAGE_G => true
		)
		port map (
			clk_i         => clk_i,
			spiClk_i      => spiClk_i,
			rst_i         => rst_i,
			dout_i        => dout_i,
			cs_o          => cs_o,
			sclk_o        => sclk_o,
			axisReadSrc_o => axisReadSrc_o,
			axisReadDst_i => axisReadDst_i,
			run_i         => run_i,
			clear_i       => clear_i,
			overflow_o    => overflow_o
		);

	stimulus1 : process
	begin
		rst_i <= '1';
		-- initialize signals
		axisReadDst_i <= AXI_4_STREAM_DST_INIT_C;
		run_i         <= '0';

		wait for CLK_PERIOD2_C*3;

		rst_i <= '0';
		------------------------------------------------------------------------
		-- reset done
		------------------------------------------------------------------------
		wait for CLK_PERIOD2_C;
		-- stimulus
		axisReadDst_i.tready <= '1';
		wait for CLK_PERIOD2_C*3;
		run_i <= '1';

		wait;

	end process stimulus1;

	stimulus2 : process
	begin
		-- initialize signals
		dout_i  <= '0';
		clear_i <= '0';

		wait for CLK_PERIOD2_C*3;
		------------------------------------------------------------------------
		-- reset done
		------------------------------------------------------------------------
		-- stimulus
		for i in 0 to 5000 loop
			counter <= to_unsigned(i, 12);
			if (i = 1000) then
				clear_i <= '1';
				wait for CLK_PERIOD2_C*5;
				clear_i <= '0';
			end if;
			WriteDataToMISO(STD_LOGIC_VECTOR(to_unsigned(i, 12)), dout_i);
		end loop;

		wait for CLK_PERIOD2_C*5;
		finish;

	end process stimulus2;


end Behavioral;
