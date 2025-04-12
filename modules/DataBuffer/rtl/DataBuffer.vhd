----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/31/2025 10:10:56 AM
-- Design Name: 
-- Module Name: DataBuffer - Behavioral
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

use IEEE.math_real."ceil";
use IEEE.math_real."log2";

use work.BramPkg.all;
use work.BramBufferPkg.all;
use work.Axi4Pkg.all;

entity DataBuffer is
    Generic (
        MARK_DEBUG_G        : string  := "false";
        NUM_ADDRESSES_G     : natural := 1024;
        PACKING_G           : natural := 2;
        SAMPLE_DATA_WIDTH_G : natural := 12;
        DATA_WIDTH_G        : natural := PACKING_G * SAMPLE_DATA_WIDTH_G;
        BYTE_WIDTH_G        : natural := DATA_WIDTH_G;
        LATENCY_G           : natural := 1;
        MEMORY_SIZE_G       : natural := NUM_ADDRESSES_G * DATA_WIDTH_G;
        ADDR_WIDTH_G        : natural := natural(ceil(log2(real(NUM_ADDRESSES_G))));
        MAX_LENGTH_G        : natural := 256;
        LENGTH_WIDTH_G      : natural := natural(ceil(log2(real(MAX_LENGTH_G))))
    );
    Port (
        clk_i : in STD_LOGIC;
        rst_i : in STD_LOGIC;

        axisWriteSrc_i : in  Axi4StreamSource;
        axisWriteDst_o : out Axi4StreamDestination;

        axiSrc_i : in  Axi4Source;
        axiDst_o : out Axi4Destination
    );
end DataBuffer;

architecture Behavioral of DataBuffer is

    subtype BramBufferSource is BramSource(
        we(DATA_WIDTH_G/BYTE_WIDTH_G-1 downto 0),
        addr(ADDR_WIDTH_G-1 downto 0),
        din(DATA_WIDTH_G-1 downto 0)
    );
    subtype BramBufferDestination is BramDestination(
        dout(DATA_WIDTH_G-1 downto 0)
    );

    signal bramWriteSrc0 : BramBufferSource;
    signal bramWriteSrc1 : BramBufferSource;
    signal writingInto   : natural range 0 to 1;
    signal bramReadSrc0  : BramBufferSource;
    signal bramReadSrc1  : BramBufferSource;
    signal bramReadDst0  : BramBufferDestination;
    signal bramReadDst1  : BramBufferDestination;
    signal readStart     : STD_LOGIC;
    signal address       : STD_LOGIC_VECTOR(ADDR_WIDTH_G-1 downto 0);
    signal length        : STD_LOGIC_VECTOR(LENGTH_WIDTH_G-1 downto 0);
    signal readDone      : STD_LOGIC;
    signal counter       : unsigned(LENGTH_WIDTH_G downto 0);
    signal dataBuffer    : TmpBufferArray(MAX_LENGTH_G-1 downto 0)(DATA_WIDTH_G-1 downto 0);
    signal readingFrom   : natural range 0 to 1;

    function getOtherBufferIndex (number : natural) return natural is
    begin
        if number = 0 then
            return 1;
        elsif number = 1 then
            return 0;
        else
            return 0;
        end if;
    end function getOtherBufferIndex;

    -----------------------------------------------------------------------------
    attribute mark_debug                  : string;
    attribute mark_debug of bramWriteSrc0 : signal is MARK_DEBUG_G;
    attribute mark_debug of bramWriteSrc1 : signal is MARK_DEBUG_G;
    attribute mark_debug of writingInto   : signal is MARK_DEBUG_G;
    attribute mark_debug of bramReadSrc0  : signal is MARK_DEBUG_G;
    attribute mark_debug of bramReadSrc1  : signal is MARK_DEBUG_G;
    attribute mark_debug of bramReadDst0  : signal is MARK_DEBUG_G;
    attribute mark_debug of bramReadDst1  : signal is MARK_DEBUG_G;
    attribute mark_debug of readStart     : signal is MARK_DEBUG_G;
    attribute mark_debug of address       : signal is MARK_DEBUG_G;
    attribute mark_debug of length        : signal is MARK_DEBUG_G;
    attribute mark_debug of readDone      : signal is MARK_DEBUG_G;
    attribute mark_debug of counter       : signal is MARK_DEBUG_G;
    attribute mark_debug of dataBuffer    : signal is MARK_DEBUG_G;
    attribute mark_debug of readingFrom   : signal is MARK_DEBUG_G;
    ----------------------------------------------------------------------------

    constant AXI_WRITE_DUMMY_C : Axi4WriteDestination := (
            AWREADY => '0',
            WREADY  => '0',
            BID     => (others => '0'),
            BRESP   => (others => '0'),
            BUSER   => (others => '0'),
            BVALID  => '0'
        );

begin
    u_BramBufferWriter : entity work.BramBufferWriter
        generic map (
            MARK_DEBUG_G        => "false",
            NUM_ADDRESSES_G     => NUM_ADDRESSES_G,
            PACKING_G           => PACKING_G,
            BYTE_WIDTH_G        => BYTE_WIDTH_G,
            SAMPLE_DATA_WIDTH_G => SAMPLE_DATA_WIDTH_G,
            ADDR_WIDTH_G        => ADDR_WIDTH_G
        )
        port map (
            clk_i           => clk_i,
            rst_i           => rst_i,
            axisWriteSrc_i  => axisWriteSrc_i,
            axisWriteDst_o  => axisWriteDst_o,
            bramWriteSrc0_o => bramWriteSrc0,
            bramWriteSrc1_o => bramWriteSrc1,
            writingInto_o   => writingInto
        );

    u_BramWrapper0 : entity work.BramWrapper
        generic map (
            MEMORY_SIZE_G => MEMORY_SIZE_G,
            ADDR_WIDTH_G  => ADDR_WIDTH_G,
            BYTE_WIDTH_G  => BYTE_WIDTH_G,
            DATA_WIDTH_G  => DATA_WIDTH_G,
            LATENCY_G     => LATENCY_G
        )
        port map (
            clk   => clk_i,
            rst   => rst_i,
            ena   => bramWriteSrc0.en,
            wea   => bramWriteSrc0.we,
            addra => bramWriteSrc0.addr,
            dina  => bramWriteSrc0.din,
            enb   => bramReadSrc0.en,
            addrb => bramReadSrc0.addr,
            doutb => bramReadDst0.dout
        );

    u_BramWrapper1 : entity work.BramWrapper
        generic map (
            MEMORY_SIZE_G => MEMORY_SIZE_G,
            ADDR_WIDTH_G  => ADDR_WIDTH_G,
            BYTE_WIDTH_G  => BYTE_WIDTH_G,
            DATA_WIDTH_G  => DATA_WIDTH_G,
            LATENCY_G     => LATENCY_G
        )
        port map (
            clk   => clk_i,
            rst   => rst_i,
            ena   => bramWriteSrc1.en,
            wea   => bramWriteSrc1.we,
            addra => bramWriteSrc1.addr,
            dina  => bramWriteSrc1.din,
            enb   => bramReadSrc1.en,
            addrb => bramReadSrc1.addr,
            doutb => bramReadDst1.dout
        );

    u_BramBufferReader : entity work.BramBufferReader
        generic map (
            MARK_DEBUG_G        => "false",
            PACKING_G           => PACKING_G,
            BYTE_WIDTH_G        => BYTE_WIDTH_G,
            SAMPLE_DATA_WIDTH_G => SAMPLE_DATA_WIDTH_G,
            LATENCY_G           => LATENCY_G,
            DATA_WIDTH_G        => DATA_WIDTH_G,
            MAX_LENGTH_G        => MAX_LENGTH_G,
            LENGTH_WIDTH_G      => LENGTH_WIDTH_G,
            ADDR_WIDTH_G        => ADDR_WIDTH_G
        )
        port map (
            clk_i          => clk_i,
            rst_i          => rst_i,
            bramReadSrc0_o => bramReadSrc0,
            bramReadSrc1_o => bramReadSrc1,
            bramReadDst0_i => bramReadDst0,
            bramReadDst1_i => bramReadDst1,
            readStart_i    => readStart,
            address_i      => address,
            length_i       => length,
            readDone_o     => readDone,
            counter_o      => counter,
            buffer_o       => dataBuffer,
            readingFrom_i  => readingFrom
        );

    readingFrom <= getOtherBufferIndex(writingInto);

    u_Axi4Interface : entity work.Axi4Interface
        generic map (
            MARK_DEBUG_G        => "false",
            PACKING_G           => PACKING_G,
            SAMPLE_DATA_WIDTH_G => SAMPLE_DATA_WIDTH_G,
            DATA_WIDTH_G        => DATA_WIDTH_G,
            MAX_LENGTH_G        => MAX_LENGTH_G,
            LENGTH_WIDTH_G      => LENGTH_WIDTH_G,
            ADDR_WIDTH_G        => ADDR_WIDTH_G
        )
        port map (
            clk_i        => clk_i,
            rst_i        => rst_i,
            axiReadSrc_i => axiSrc_i.rd,
            axiReadDst_o => axiDst_o.rd,
            readStart_o  => readStart,
            address_o    => address,
            length_o     => length,
            readDone_i   => readDone,
            counter_i    => counter,
            buffer_i     => dataBuffer
        );

    axiDst_o.wr <= AXI_WRITE_DUMMY_C;

end Behavioral;
