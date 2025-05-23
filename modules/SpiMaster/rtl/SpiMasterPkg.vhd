----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Stas Bucik
-- 
-- Create Date: 03/31/2025 01:28:32 PM
-- Design Name: 
-- Module Name: SpiMasterPkg - 
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