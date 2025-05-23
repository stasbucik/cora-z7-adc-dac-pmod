----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Stas Bucik
-- 
-- Create Date: 03/31/2025 01:28:32 PM
-- Design Name: 
-- Module Name: DacAD5451Pkg - 
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

package DacAD5451Pkg is

	constant AD5451_SPI_CPOL_C : SpiClockPolarity := SPI_CPOL_0;
	constant AD5451_SPI_CPHA_C : SpiClockPhase    := SPI_CPHA_1;

	-- CS must be asserted for 16 bits
	constant AD5451_SPI_DATA_WIDTH_C : natural := 16;

	-- DAC resolution is 10 bits
	constant AD5451_DATA_WIDTH_C    : natural := 10;
	constant AD5451_COMMAND_WIDTH_C : natural := 2;

	-- Axi stream constants
	constant AD5451_AXI_DATA_WIDTH_C : natural := 16;
	constant AD5451_PADDING_WIDTH_C  : natural := AD5451_SPI_DATA_WIDTH_C - AD5451_COMMAND_WIDTH_C - AD5451_DATA_WIDTH_C;

	alias AD5451Axi4StreamSource is SpiMasterAxi4StreamSource;

end package DacAD5451Pkg;

package body DacAD5451Pkg is

end package body DacAD5451Pkg;