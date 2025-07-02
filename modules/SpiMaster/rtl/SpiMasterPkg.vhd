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

package SpiMasterPkg is

	constant SPI_MASTER_DATA_WIDTH_C     : natural := 16;
	constant SPI_MASTER_AXI_DATA_WIDTH_C : natural := 16;

	subtype SpiMasterAxi4StreamSource is Axi4StreamSource(
		TDATA(SPI_MASTER_DATA_WIDTH_C-1 downto 0),
		TSTRB(SPI_MASTER_DATA_WIDTH_C/8-1 downto 0),
		TKEEP(SPI_MASTER_DATA_WIDTH_C/8-1 downto 0)
	);

end package SpiMasterPkg;

package body SpiMasterPkg is

end package body SpiMasterPkg;