----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Stas Bucik
-- 
-- Create Date: 03/31/2025 10:10:56 AM
-- Design Name: 
-- Module Name: BramBufferReader - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
use work.BramPkg.all;
use work.BramBufferPkg.all;
use work.Axi4Pkg.all;

use IEEE.math_real."ceil";
use IEEE.math_real."log2";

entity BramBufferReader is
    generic(
        MARK_DEBUG_G        : string  := "false";
        PACKING_G           : natural := 2;
        BYTE_WIDTH_G        : natural := 4;
        SAMPLE_DATA_WIDTH_G : natural := 12;
        LATENCY_G           : natural := 1;
        DATA_WIDTH_G        : natural := PACKING_G * SAMPLE_DATA_WIDTH_G;
        MAX_LENGTH_G        : natural := 16;
        LENGTH_WIDTH_G      : natural := natural(ceil(log2(real(MAX_LENGTH_G))));
        ADDR_WIDTH_G        : natural := natural(ceil(log2(real(1024))))
    );
    Port (
        clk_i : in STD_LOGIC;
        rst_i : in STD_LOGIC;

        bramReadSrc0_o : out BramSource;
        bramReadSrc1_o : out BramSource;
        bramReadDst0_i : in  BramDestination;
        bramReadDst1_i : in  BramDestination;

        readStart_i : in STD_LOGIC;
        address_i   : in STD_LOGIC_VECTOR(ADDR_WIDTH_G-1 downto 0);
        length_i    : in STD_LOGIC_VECTOR(LENGTH_WIDTH_G-1 downto 0);

        firstReady_o : out STD_LOGIC;

        buffer_o      : out TmpBufferArray(MAX_LENGTH_G-1 downto 0)(DATA_WIDTH_G-1 downto 0);
        readingFrom_i : in  natural range 0 to 1;

        overwrite_o      : out STD_LOGIC;
        clearOverwrite_o : out STD_LOGIC

    );
end BramBufferReader;

architecture Behavioral of BramBufferReader is

    type StateType is (
            IDLE_S,
            LATENCY_COUNT_S,
            GET_DATA_BRAM_S
        );

    type RegType is record
        state : StateType;
        -- Start address to read
        addr : unsigned(ADDR_WIDTH_G-1 downto 0);
        -- How many addresses to read
        len : unsigned(LENGTH_WIDTH_G-1 downto 0);
        -- Count how many addresses have been read
        transferCounter : unsigned(LENGTH_WIDTH_G downto 0);
        -- Count how many cycles to first data from ram
        latencyCounter : natural range 0 to LATENCY_G;
        -- Ram read enable
        enables : STD_LOGIC_VECTOR(1 downto 0);
        -- Temporary buffer for data that was read
        tmpBuffer : TmpBufferArray(MAX_LENGTH_G-1 downto 0)(DATA_WIDTH_G-1 downto 0);
        -- Which ram to read from
        readingFrom : natural range 0 to 1;
        -- Which ram was used when ofset of 0 was read
        readingFromStart : natural range 0 to 1;
        -- Signal if buffer could be overwritten
        overwrite : STD_LOGIC;
        -- Clear overwrite flag
        clearOverwrite : STD_LOGIC;
    end record RegType;

    constant REG_TYPE_INIT_C : RegType := (
            state            => IDLE_S,
            addr             => (others => '0'),
            len              => (others => '0'),
            transferCounter  => (others => '0'),
            latencyCounter   => 0,
            enables          => (others => '0'),
            tmpBuffer        => (others => (others => '0')),
            readingFrom      => 0,
            readingFromStart => 0,
            overwrite        => '0',
            clearOverwrite   => '0'
        );

    constant START_ADDRESS : STD_LOGIC_VECTOR(ADDR_WIDTH_G-1 downto 0) := (others => '0');

    signal r   : RegType;
    signal rin : RegType;

    -----------------------------------------------------------------------------
    attribute mark_debug        : string;
    attribute mark_debug of r   : signal is MARK_DEBUG_G;
    attribute mark_debug of rin : signal is MARK_DEBUG_G;
    ----------------------------------------------------------------------------

begin

    p_Comb     : process(all)
        variable v : RegType;
    begin
        v := r;

        v.overwrite      := '0';
        v.clearOverwrite := '0';

        -- combinatorial logic
        case r.state is
            when IDLE_S =>
                -- Reset counter
                v.transferCounter := (others => '0');

                if (readStart_i = '1') then
                    -- Capture start address and length
                    v.addr := unsigned(address_i);
                    v.len  := unsigned(length_i);

                    if (address_i = START_ADDRESS) then
                        -- Remember which ram was used when read started
                        v.clearOverwrite   := '1';
                        v.readingFromStart := readingFrom_i;
                    else
                        if (r.readingFromStart /= readingFrom_i) then
                            -- Signal overwrite if reading from different ram
                            v.overwrite := '1';
                        end if;
                    end if;

                    -- Capture which ram to read from
                    v.readingFrom := readingFrom_i;

                    -- Enable read
                    case readingFrom_i is
                        when 0 =>
                            v.enables := "01";
                        when 1 =>
                            v.enables := "10";
                        when others =>
                            v.enables := "00";
                    end case;

                    if (LATENCY_G > 1) then
                        v.state := LATENCY_COUNT_S;
                    else
                        v.state := GET_DATA_BRAM_S;
                    end if;
                end if;

            when LATENCY_COUNT_S =>
                -- Wait for the first data to be read from ram
                if (r.latencyCounter < LATENCY_G-2) then
                    v.latencyCounter := r.latencyCounter + 1;
                else
                    v.state := GET_DATA_BRAM_S;
                end if;

                if (r.latencyCounter = r.len) then
                    -- Stop reading
                    v.enables := "00";
                else
                    -- Read next location
                    v.addr := r.addr + 1;
                end if;

            when GET_DATA_BRAM_S =>
                v.transferCounter := r.transferCounter + 1;

                if (r.latencyCounter + r.transferCounter = r.len - 1) then
                    -- Stop reading
                    v.enables := "00";
                else
                    -- Read next location
                    v.addr := r.addr + 1;
                end if;

                if (r.transferCounter = r.len) then
                    v.latencyCounter := 0;
                    v.state          := IDLE_S;
                end if;

                -- Store read data to temporary buffer
                case r.readingFrom is
                    when 0 =>
                        v.tmpBuffer(to_integer(r.transferCounter)) := bramReadDst0_i.dout;
                    when 1 =>
                        v.tmpBuffer(to_integer(r.transferCounter)) := bramReadDst1_i.dout;
                    when others =>
                        v.tmpBuffer(to_integer(r.transferCounter)) := (others => '0');
                end case;

            when others =>
                v := REG_TYPE_INIT_C;
        end case;

        if (rst_i = '1') then
            v := REG_TYPE_INIT_C;
        end if;

        rin <= v;

        -- Drive outputs
        bramReadSrc0_o.we   <= (others => '0');
        bramReadSrc0_o.en   <= rin.enables(0);
        bramReadSrc0_o.addr <= STD_LOGIC_VECTOR(rin.addr);
        bramReadSrc0_o.din  <= (others => '0');

        bramReadSrc1_o.we   <= (others => '0');
        bramReadSrc1_o.en   <= rin.enables(1);
        bramReadSrc1_o.addr <= STD_LOGIC_VECTOR(rin.addr);
        bramReadSrc1_o.din  <= (others => '0');

        firstReady_o     <= '0' when r.transferCounter = 0 else '1';
        buffer_o         <= r.tmpBuffer;
        overwrite_o      <= r.overwrite;
        clearOverwrite_o <= r.clearOverwrite;
    end process p_Comb;

    p_Seq : process(clk_i)
    begin
        if rising_edge(clk_i) then
            r <= rin;
        end if;
    end process p_Seq;

end Behavioral;
