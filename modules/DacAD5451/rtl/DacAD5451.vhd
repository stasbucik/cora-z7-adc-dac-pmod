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
use work.DacAD5451Pkg.all;

entity DacAD5451 is
    Generic (
        MARK_DEBUG_G : string  := "false";
        SYNC_STAGE_G : boolean := true
    );
    Port (
        clk_i    : in STD_LOGIC;
        spiClk_i : in STD_LOGIC;
        rst_i    : in STD_LOGIC;

        -- SPI interface
        sdin_o  : out STD_LOGIC;
        sync_o  : out STD_LOGIC;
        sclk_o  : out STD_LOGIC;
        highz_o : out STD_LOGIC;

        -- Write interface
        axisWriteSrc_i : in  AD5451Axi4StreamSource;
        axisWriteDst_o : out Axi4StreamDestination;
        run_i          : in  STD_LOGIC;
        clear_i        : in  STD_LOGIC
    );
end DacAD5451;

architecture Behavioral of DacAD5451 is

    constant AXI_4_STREAM_SINK_C : Axi4StreamDestination := (
            TREADY => '1'
        );

    -- Control register value for DAC, it signals normal operation
    constant SPI_COMMAND_C : STD_LOGIC_VECTOR(AD5451_COMMAND_WIDTH_C-1 downto 0)   := (others => '0');
    constant SPI_PADDING_C : STD_LOGIC_VECTOR(AD5451_PADDING_WIDTH_C - 1 downto 0) := (others => '0');

    signal axisSrcDataRemap : axisWriteSrc_i'subtype;
    signal axisDummy        : axisWriteSrc_i'subtype;

begin

    -- Remap number representing the analog value to data sent over SPI 
    -- 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0
    -- C1 C0  9  8  7  6  5  4  3  2  1  0  x  x  x  x
    axisSrcDataRemap.TDATA   <= SPI_COMMAND_C & axisWriteSrc_i.TDATA(AD5451_DATA_WIDTH_C-1 downto 0) & SPI_PADDING_C;
    axisSrcDataRemap.TVALID  <= axisWriteSrc_i.TVALID;
    axisSrcDataRemap.TSTRB   <= axisWriteSrc_i.TSTRB;
    axisSrcDataRemap.TKEEP   <= axisWriteSrc_i.TKEEP;
    axisSrcDataRemap.TLAST   <= axisWriteSrc_i.TLAST;
    axisSrcDataRemap.TID     <= axisWriteSrc_i.TID;
    axisSrcDataRemap.TDEST   <= axisWriteSrc_i.TDEST;
    axisSrcDataRemap.TUSER   <= axisWriteSrc_i.TUSER;
    axisSrcDataRemap.TWAKEUP <= axisWriteSrc_i.TWAKEUP;

    syncSpi_g : if (SYNC_STAGE_G = false) generate
        u_SpiMaster2Axis : entity work.SpiMaster2Axis
            generic map (
                MARK_DEBUG_G    => "false",
                SPI_CPOL_G      => AD5451_SPI_CPOL_C,
                SPI_CPHA_G      => AD5451_SPI_CPHA_C,
                DATA_WIDTH_G    => AD5451_SPI_DATA_WIDTH_C,
                N_CYCLES_IDLE_G => 1
            )
            port map (
                clk_i          => clk_i,
                rst_i          => rst_i,
                miso_i         => '0',
                mosi_o         => sdin_o,
                cs_o           => sync_o,
                clk_o          => sclk_o,
                highz_o        => highz_o,
                axisWriteSrc_i => axisSrcDataRemap,
                axisWriteDst_o => axisWriteDst_o,
                axisReadSrc_o  => axisDummy,
                axisReadDst_i  => AXI_4_STREAM_SINK_C,
                run_i          => run_i,
                overflow_o     => open
            );
    end generate syncSpi_g;

    asyncSpi_g : if (SYNC_STAGE_G = true) generate
        u_SpiMaster : entity work.SpiMaster
            generic map (
                MARK_DEBUG_G    => "false",
                SPI_CPOL_G      => AD5451_SPI_CPOL_C,
                SPI_CPHA_G      => AD5451_SPI_CPHA_C,
                DATA_WIDTH_G    => AD5451_SPI_DATA_WIDTH_C,
                N_CYCLES_IDLE_G => 1,
                UNUSED_READ_G   => true,
                UNUSED_WRITE_G  => false
            )
            port map (
                clk_i          => clk_i,
                spiClk_i       => spiClk_i,
                rst_i          => rst_i,
                miso_i         => '0',
                mosi_o         => sdin_o,
                cs_o           => sync_o,
                clk_o          => sclk_o,
                highz_o        => highz_o,
                axisWriteSrc_i => axisSrcDataRemap,
                axisWriteDst_o => axisWriteDst_o,
                axisReadSrc_o  => axisDummy,
                axisReadDst_i  => AXI_4_STREAM_SINK_C,
                run_i          => run_i,
                clear_i        => clear_i,
                overflow_o     => open
            );
    end generate asyncSpi_g;
end Behavioral;
