----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
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
        MAX_LENGTH_G        : natural := 256;
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

        readDone_o : out STD_LOGIC;
        counter_o  : out unsigned(LENGTH_WIDTH_G-1 downto 0);

        buffer_o      : out TmpBufferArray(MAX_LENGTH_G-1 downto 0)(DATA_WIDTH_G-1 downto 0);
        readingFrom_i : out natural range 0 to 1

    );
end BramBufferReader;

architecture Behavioral of BramBufferReader is

    type StateType is (
            IDLE_S,
            LATENCY_COUNT_S,
            GET_DATA_BRAM_S
        );

    type RegType is record
        state           : StateType;
        addr            : unsigned(ADDR_WIDTH_G-1 downto 0);
        len             : unsigned(LENGTH_WIDTH_G-1 downto 0);
        transferCounter : unsigned(LENGTH_WIDTH_G-1 downto 0);
        latencyCounter  : natural range 0 to LATENCY_G;
        enables         : STD_LOGIC_VECTOR(1 downto 0);
        tmpBuffer       : TmpBufferArray(MAX_LENGTH_G-1 downto 0)(DATA_WIDTH_G-1 downto 0);
        readDone        : STD_LOGIC;
    end record RegType;

    constant REG_TYPE_INIT_C : RegType := (
            state           => IDLE_S,
            addr            => (others => '0'),
            len             => (others => '0'),
            transferCounter => (others => '0'),
            latencyCounter  => 0,
            enables         => (others => '0'),
            tmpBuffer       => (others => (others => '0')),
            readDone        => '0'
        );

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

        v.readDone := '0';

        -- combinatorial logic
        case r.state is
            when IDLE_S =>
                if (readStart_i = '1') then
                    v.addr            := unsigned(address_i);
                    v.len             := unsigned(length_i);
                    v.transferCounter := (others => '0');

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
                if (r.latencyCounter < LATENCY_G-2) then
                    v.latencyCounter := r.latencyCounter + 1;
                else
                    v.state := GET_DATA_BRAM_S;
                end if;

                if (r.latencyCounter = r.len) then
                    v.enables := "00";
                else
                    v.addr := r.addr + 1;
                end if;

            when GET_DATA_BRAM_S =>
                if (r.latencyCounter + r.transferCounter = r.len) then
                    v.enables := "00";
                else
                    v.addr := r.addr + 1;
                end if;

                if (r.transferCounter = r.len) then
                    v.latencyCounter := 0;
                    v.state          := IDLE_S;
                    v.readDone       := '1';
                end if;
                v.tmpBuffer(to_integer(r.transferCounter)) := bramReadDst0_i.dout;
                v.transferCounter                          := r.transferCounter + 1;

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

        readDone_o <= r.readDone;
        counter_o  <= r.transferCounter;
        buffer_o   <= r.tmpBuffer;
    end process p_Comb;

    p_Seq : process(clk_i)
    begin
        if rising_edge(clk_i) then
            r <= rin;
        end if;
    end process p_Seq;

end Behavioral;
