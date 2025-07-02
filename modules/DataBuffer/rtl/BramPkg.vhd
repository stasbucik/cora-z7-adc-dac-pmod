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

package BramPkg is

	----------------------------------------------------------------------------
	type BramSource is record
		en   : STD_LOGIC;
		we   : STD_LOGIC_VECTOR;
		addr : STD_LOGIC_VECTOR;
		din  : STD_LOGIC_VECTOR;
	end record BramSource;

	type BramDestination is record
		dout : STD_LOGIC_VECTOR;
	end record BramDestination;

end package BramPkg;

package body BramPkg is
end package body BramPkg;