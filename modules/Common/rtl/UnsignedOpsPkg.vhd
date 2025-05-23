----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Stas Bucik
-- 
-- Create Date: 
-- Design Name: 
-- Module Name: UnsignedOpsPkg - 
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

package UnsignedOpsPkg is

	function max (
			a : integer;
			b : integer
		) return integer;

	function uAdd (
			a : unsigned;
			b : unsigned
		) return unsigned;

	function uSub (
			a : unsigned;
			b : unsigned
		) return unsigned;

	function uEq (
			a : unsigned;
			b : unsigned
		) return boolean;

	function uLeq (
			a : unsigned;
			b : unsigned
		) return boolean;

end package UnsignedOpsPkg;

package body UnsignedOpsPkg is

	function max (
			a : integer;
			b : integer
		) return integer is
	begin
		if (a > b) then
			return a;
		else
			return b;
		end if;
	end function max;

	function uAdd (
			a : unsigned;
			b : unsigned
		) return unsigned is
		constant padding : STD_LOGIC_VECTOR(abs(a'length - b'length)-1 downto 0) := (others => '0');
		variable tmp     : STD_LOGIC_VECTOR(max(a'length, b'length)-1 downto 0);
	begin
		if (a'length > b'length) then
			tmp := padding & STD_LOGIC_VECTOR(b);
			return a + unsigned(tmp);
		elsif (a'length < b'length) then
			tmp := padding & STD_LOGIC_VECTOR(a);
			return unsigned(tmp) + b;
		else
			return a + b;
		end if;
	end function uAdd;

	function uSub (
			a : unsigned;
			b : unsigned
		) return unsigned is
		constant padding : STD_LOGIC_VECTOR(abs(a'length - b'length)-1 downto 0) := (others => '0');
		variable tmp     : STD_LOGIC_VECTOR(max(a'length, b'length)-1 downto 0);
	begin
		if (a'length > b'length) then
			tmp := padding & STD_LOGIC_VECTOR(b);
			return a - unsigned(tmp);
		elsif (a'length < b'length) then
			tmp := padding & STD_LOGIC_VECTOR(a);
			return unsigned(tmp) - b;
		else
			return a - b;
		end if;
	end function uSub;

	function uEq (
			a : unsigned;
			b : unsigned
		) return boolean is
		constant padding : STD_LOGIC_VECTOR(abs(a'length - b'length)-1 downto 0) := (others => '0');
		variable tmp     : STD_LOGIC_VECTOR(max(a'length, b'length)-1 downto 0);
	begin
		if (a'length > b'length) then
			tmp := padding & STD_LOGIC_VECTOR(b);
			return a = unsigned(tmp);
		elsif (a'length < b'length) then
			tmp := padding & STD_LOGIC_VECTOR(a);
			return unsigned(tmp) = b;
		else
			return a = b;
		end if;
	end function uEq;

	function uLeq (
			a : unsigned;
			b : unsigned
		) return boolean is
		constant padding : STD_LOGIC_VECTOR(abs(a'length - b'length)-1 downto 0) := (others => '0');
		variable tmp     : STD_LOGIC_VECTOR(max(a'length, b'length)-1 downto 0);
	begin
		if (a'length > b'length) then
			tmp := padding & STD_LOGIC_VECTOR(b);

			return a <= unsigned(tmp);
		elsif (a'length < b'length) then
			tmp := padding & STD_LOGIC_VECTOR(a);

			return unsigned(tmp) <= b;
		else
			return a <= b;
		end if;
	end function uLeq;

end package body UnsignedOpsPkg;