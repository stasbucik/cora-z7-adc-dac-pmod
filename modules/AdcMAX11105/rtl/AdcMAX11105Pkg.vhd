----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/31/2025 01:28:32 PM
-- Design Name: 
-- Module Name: AdcMAX11105Pkg - 
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
use IEEE.NUMERIC_STD.ALL;

use work.Axi4Pkg.all;
use work.SpiMaster2AxisPkg.all;
use work.SpiMasterPkg.all;

package AdcMAX11105Pkg is

	constant MAX11105_SPI_CPOL_C : SpiClockPolarity := SPI_CPOL_0;
	constant MAX11105_SPI_CPHA_C : SpiClockPhase    := SPI_CPHA_0;

	constant MAX11105_SPI_DATA_WIDTH_C    : natural := 14;
	constant MAX11105_SPI_BIT_WIDTH_C     : natural := 16;
	constant MAX11105_SPI_CS_HIGH_WIDTH_C : natural := MAX11105_SPI_BIT_WIDTH_C - MAX11105_SPI_DATA_WIDTH_C;
	constant MAX11105_DATA_WIDTH_C        : natural := 12;
	constant MAX11105_DATA_OFFSET_C       : natural := 1;
	constant MAX11105_AXI_DATA_WIDTH_C    : natural := 16;
	constant MAX11105_AXI_PADDING_WIDTH_C : natural := MAX11105_AXI_DATA_WIDTH_C - MAX11105_DATA_WIDTH_C;

	alias MAX11105Axi4StreamSource is SpiMasterAxi4StreamSource;

end package AdcMAX11105Pkg;

package body AdcMAX11105Pkg is

end package body AdcMAX11105Pkg;