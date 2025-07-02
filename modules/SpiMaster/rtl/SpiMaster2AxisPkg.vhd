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

package SpiMaster2AxisPkg is

	type SpiClockPolarity is (
			SPI_CPOL_0, -- Clock idles low
			SPI_CPOL_1  -- Clock idles high
		);

	type SpiClockPhase is (
			-- The first data bit is output immediately when SS activates.
			-- Subsequent bits are output when SCLK transitions to its idle voltage level.
			-- Sampling occurs when SCLK transitions from its idle voltage level.
			SPI_CPHA_0,

			-- The first data bit is output on SCLK's first clock edge after SS activates.
			-- Subsequent bits are output when SCLK transitions from its idle voltage level.
			-- Sampling occurs when SCLK transitions to its idle voltage level.
			SPI_CPHA_1
		);

	function getIdleLevel (
			cp : SpiClockPolarity
		) return STD_LOGIC;

	function getActiveLevel (
			cp : SpiClockPolarity
		) return STD_LOGIC;

end package SpiMaster2AxisPkg;

package body SpiMaster2AxisPkg is

	function getIdleLevel (
			cp : SpiClockPolarity
		) return STD_LOGIC is
	begin
		if cp = SPI_CPOL_0 then
			return '0';
		elsif cp = SPI_CPOL_1 then
			return '1';
		end if;
	end function getIdleLevel;

	function getActiveLevel (
			cp : SpiClockPolarity
		) return STD_LOGIC is
	begin
		if cp = SPI_CPOL_0 then
			return '1';
		elsif cp = SPI_CPOL_1 then
			return '0';
		end if;
	end function getActiveLevel;

end package body SpiMaster2AxisPkg;