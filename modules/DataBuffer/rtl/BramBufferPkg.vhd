library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.BramPkg.all;

use IEEE.math_real."ceil";
use IEEE.math_real."log2";

package BramBufferPkg is

	constant BRAM_BUFFER_NUM_ADDRESSES_C     : natural := 1024;
	constant BRAM_BUFFER_PACKING_C           : natural := 2;
	constant BRAM_BUFFER_SAMPLE_DATA_WIDTH_C : natural := 12;
	constant BRAM_BUFFER_DATA_WIDTH_C        : natural := BRAM_BUFFER_PACKING_C * BRAM_BUFFER_SAMPLE_DATA_WIDTH_C;
	constant BRAM_BUFFER_BYTE_WIDTH_C        : natural := BRAM_BUFFER_DATA_WIDTH_C;
	constant BRAM_BUFFER_LATENCY_C           : natural := 1;
	constant BRAM_BUFFER_MEMORY_SIZE_C       : natural := BRAM_BUFFER_NUM_ADDRESSES_C * BRAM_BUFFER_DATA_WIDTH_C;
	constant BRAM_BUFFER_ADDR_WIDTH_C        : natural := natural(ceil(log2(real(BRAM_BUFFER_NUM_ADDRESSES_C))));
	constant BRAM_BUFFER_MAX_LENGTH_C        : natural := 256;
	constant BRAM_BUFFER_LENGTH_WIDTH_C      : natural := natural(ceil(log2(real(BRAM_BUFFER_MAX_LENGTH_C))));

	subtype BramBufferSource is BramSource(
		we(BRAM_BUFFER_DATA_WIDTH_C/BRAM_BUFFER_BYTE_WIDTH_C-1 downto 0),
		addr(BRAM_BUFFER_ADDR_WIDTH_C-1 downto 0),
		din(BRAM_BUFFER_DATA_WIDTH_C-1 downto 0)
	);
	subtype BramBufferDestination is BramDestination(
		dout(BRAM_BUFFER_DATA_WIDTH_C-1 downto 0)
	);

	constant BRAM_BUFFER_SRC_INIT_C : BramBufferSource := (
			en   => '0',
			we   => (others => '0'),
			addr => (others => '0'),
			din  => (others => '0')
		);
	constant BRAM_BUFFER_DST_INIT_C : BramBufferDestination := (
			dout => (others => '0')
		);

	type TmpBufferArray is array (natural range <>) of STD_LOGIC_VECTOR;

end package BramBufferPkg;

package body BramBufferPkg is
end package body BramBufferPkg;