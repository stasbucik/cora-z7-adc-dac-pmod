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

package AdcMAX11105Pkg is

	constant MAX11105_SPI_CPOL_C : SpiClockPolarity := SPI_CPOL_0;
	constant MAX11105_SPI_CPHA_C : SpiClockPhase    := SPI_CPHA_1;

	-- CS must be asserted for 14 bits
	constant MAX11105_SPI_DATA_WIDTH_C : natural := 14;

	-- The period must be 16 cycles, CS must be high for 2 cycles
	constant MAX11105_SPI_BIT_WIDTH_C     : natural := 16;
	constant MAX11105_SPI_CS_HIGH_WIDTH_C : natural := MAX11105_SPI_BIT_WIDTH_C - MAX11105_SPI_DATA_WIDTH_C - 1;

	-- ADC resolution is 12 bits
	constant MAX11105_DATA_WIDTH_C : natural := 12;

	-- ADC data is transmitted with 1 bit offset
	constant MAX11105_DATA_OFFSET_C : natural := 1;

	-- Axi stream constants
	constant MAX11105_AXI_DATA_WIDTH_C    : natural := 16;
	constant MAX11105_AXI_PADDING_WIDTH_C : natural := MAX11105_AXI_DATA_WIDTH_C - MAX11105_DATA_WIDTH_C;

	alias MAX11105Axi4StreamSource is SpiMasterAxi4StreamSource;

end package AdcMAX11105Pkg;

package body AdcMAX11105Pkg is

end package body AdcMAX11105Pkg;