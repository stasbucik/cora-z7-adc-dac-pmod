----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/31/2025 01:28:32 PM
-- Design Name: 
-- Module Name: SpiAdapterPkg - 
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

--use IEEE.NUMERIC_STD.ALL;

package SpiAdapterPkg is

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

end package SpiAdapterPkg;

package body SpiAdapterPkg is

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

end package body SpiAdapterPkg;