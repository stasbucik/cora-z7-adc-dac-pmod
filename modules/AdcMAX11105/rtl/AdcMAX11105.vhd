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

use work.Axi4Pkg.all;
use work.AdcMAX11105Pkg.all;

entity AdcMAX11105 is
    Generic (
        MARK_DEBUG_G : string  := "false";
        SYNC_STAGE_G : boolean := true
    );
    Port (
        clk_i    : in STD_LOGIC;
        spiClk_i : in STD_LOGIC;
        rst_i    : in STD_LOGIC;

        -- SPI interface
        dout_i : in  STD_LOGIC;
        cs_o   : out STD_LOGIC;
        sclk_o : out STD_LOGIC;

        -- Write interface
        axisReadSrc_o : out MAX11105Axi4StreamSource;
        axisReadDst_i : in  Axi4StreamDestination;
        run_i         : in  STD_LOGIC;
        clear_i       : in  STD_LOGIC;
        overflow_o    : out STD_LOGIC
    );
end AdcMAX11105;

architecture Behavioral of AdcMAX11105 is

    constant AXI_4_STREAM_SINK_C : axisReadSrc_o'subtype := (
            TVALID  => '1',
            TDATA   => (others => '0'),
            TSTRB   => (others => '0'),
            TKEEP   => (others => '0'),
            TLAST   => '0',
            TID     => (others => '0'),
            TDEST   => (others => '0'),
            TUSER   => (others => '0'),
            TWAKEUP => '0'
        );

    constant AXIS_PADDING_C : STD_LOGIC_VECTOR(MAX11105_AXI_PADDING_WIDTH_C-1 downto 0) := (others => '0');

    signal axisSrcDataRemap : axisReadSrc_o'subtype;

    ----------------------------------------------------------------------------
    attribute mark_debug          : string;
    attribute mark_debug of run_i : signal is MARK_DEBUG_G;
    ----------------------------------------------------------------------------

begin

    -- Remap raw data read from SPI to actual number representing the analog value
    -- 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0
    --  x  x  x  x  x  9  8  7  6  5  4  3  2  1  0  x
    axisReadSrc_o.TDATA <= AXIS_PADDING_C & axisSrcDataRemap.TDATA(
            MAX11105_SPI_DATA_WIDTH_C - 1 - MAX11105_DATA_OFFSET_C downto
            MAX11105_SPI_DATA_WIDTH_C - MAX11105_DATA_OFFSET_C - MAX11105_DATA_WIDTH_C
    );
    axisReadSrc_o.TVALID  <= axisSrcDataRemap.TVALID;
    axisReadSrc_o.TSTRB   <= axisSrcDataRemap.TSTRB;
    axisReadSrc_o.TKEEP   <= axisSrcDataRemap.TKEEP;
    axisReadSrc_o.TLAST   <= axisSrcDataRemap.TLAST;
    axisReadSrc_o.TID     <= axisSrcDataRemap.TID;
    axisReadSrc_o.TDEST   <= axisSrcDataRemap.TDEST;
    axisReadSrc_o.TUSER   <= axisSrcDataRemap.TUSER;
    axisReadSrc_o.TWAKEUP <= axisSrcDataRemap.TWAKEUP;

    syncSpi_g : if (SYNC_STAGE_G = false) generate
        u_SpiMaster2Axis : entity work.SpiMaster2Axis
            generic map (
                MARK_DEBUG_G    => "false",
                SPI_CPOL_G      => MAX11105_SPI_CPOL_C,
                SPI_CPHA_G      => MAX11105_SPI_CPHA_C,
                DATA_WIDTH_G    => MAX11105_SPI_DATA_WIDTH_C,
                N_CYCLES_IDLE_G => MAX11105_SPI_CS_HIGH_WIDTH_C
            )
            port map (
                clk_i          => clk_i,
                rst_i          => rst_i,
                miso_i         => dout_i,
                mosi_o         => open,
                cs_o           => cs_o,
                clk_o          => sclk_o,
                highz_o        => open,
                axisWriteSrc_i => AXI_4_STREAM_SINK_C,
                axisWriteDst_o => open,
                axisReadSrc_o  => axisSrcDataRemap,
                axisReadDst_i  => axisReadDst_i,
                run_i          => run_i,
                overflow_o     => overflow_o
            );
    end generate syncSpi_g;

    asyncSpi_g : if (SYNC_STAGE_G = true) generate
        u_SpiMaster : entity work.SpiMaster
            generic map (
                MARK_DEBUG_G    => "false",
                SPI_CPOL_G      => MAX11105_SPI_CPOL_C,
                SPI_CPHA_G      => MAX11105_SPI_CPHA_C,
                DATA_WIDTH_G    => MAX11105_SPI_DATA_WIDTH_C,
                N_CYCLES_IDLE_G => MAX11105_SPI_CS_HIGH_WIDTH_C,
                UNUSED_READ_G   => false,
                UNUSED_WRITE_G  => true
            )
            port map (
                clk_i          => clk_i,
                spiClk_i       => spiClk_i,
                rst_i          => rst_i,
                miso_i         => dout_i,
                mosi_o         => open,
                cs_o           => cs_o,
                clk_o          => sclk_o,
                highz_o        => open,
                axisWriteSrc_i => AXI_4_STREAM_SINK_C,
                axisWriteDst_o => open,
                axisReadSrc_o  => axisSrcDataRemap,
                axisReadDst_i  => axisReadDst_i,
                run_i          => run_i,
                clear_i        => clear_i,
                overflow_o     => overflow_o
            );
    end generate asyncSpi_g;
end Behavioral;
