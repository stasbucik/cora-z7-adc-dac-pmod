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
use work.BramPkg.all;

use IEEE.math_real."ceil";
use IEEE.math_real."log2";

package BramBufferPkg is

	constant BRAM_BUFFER_NUM_ADDRESSES_C : natural := 1024 * 4;

	-- Pack samples in groups of 2, so 24 bits worth of samples are in one memory location.
	-- This maximizes the data rate on GP AXI, since it is 32 bits wide.
	constant BRAM_BUFFER_PACKING_C : natural := 2;

	-- ADC outputs 12 bit samples
	constant BRAM_BUFFER_SAMPLE_DATA_WIDTH_C : natural := 12;
	constant BRAM_BUFFER_DATA_WIDTH_C        : natural := BRAM_BUFFER_PACKING_C * BRAM_BUFFER_SAMPLE_DATA_WIDTH_C;
	constant BRAM_BUFFER_BYTE_WIDTH_C        : natural := BRAM_BUFFER_DATA_WIDTH_C;
	constant BRAM_BUFFER_LATENCY_C           : natural := 1;
	constant BRAM_BUFFER_MEMORY_SIZE_C       : natural := BRAM_BUFFER_NUM_ADDRESSES_C * BRAM_BUFFER_DATA_WIDTH_C;
	constant BRAM_BUFFER_ADDR_WIDTH_C        : natural := natural(ceil(log2(real(BRAM_BUFFER_NUM_ADDRESSES_C))));

	-- Maximum Axi burst length on GP is 8, this was tested with a kernel module. memcpy_fromio caps out at 8.
	constant BRAM_BUFFER_MAX_LENGTH_C   : natural := 8;
	constant BRAM_BUFFER_LENGTH_WIDTH_C : natural := natural(ceil(log2(real(BRAM_BUFFER_MAX_LENGTH_C))));

	type TmpBufferArray is array (natural range <>) of STD_LOGIC_VECTOR;

end package BramBufferPkg;

package body BramBufferPkg is
end package body BramBufferPkg;