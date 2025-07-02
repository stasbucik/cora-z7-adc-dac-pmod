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