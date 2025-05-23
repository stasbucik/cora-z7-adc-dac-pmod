----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Stas Bucik
-- 
-- Create Date: 
-- Design Name: 
-- Module Name: BramPkg - 
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