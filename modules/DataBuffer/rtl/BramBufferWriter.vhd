----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/31/2025 10:10:56 AM
-- Design Name: 
-- Module Name: BramBufferWriter - Behavioral
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
use work.Axi4Pkg.all;

use IEEE.math_real."ceil";
use IEEE.math_real."log2";

entity BramBufferWriter is
    generic(
        MARK_DEBUG_G        : string  := "false";
        NUM_ADDRESSES_G     : natural := 1024;
        PACKING_G           : natural := 2;
        BYTE_WIDTH_G        : natural := 4;
        SAMPLE_DATA_WIDTH_G : natural := 12;
        ADDR_WIDTH_G        : natural := natural(ceil(log2(real(NUM_ADDRESSES_G))))
    );
    Port (
        clk_i : in STD_LOGIC;
        rst_i : in STD_LOGIC;

        axisWriteSrc_i : in  Axi4StreamSource;
        axisWriteDst_o : out Axi4StreamDestination;

        bramWriteSrc0_o : out BramSource;
        bramWriteSrc1_o : out BramSource;

        writingInto_o : out natural range 0 to 1
    );
end BramBufferWriter;

architecture Behavioral of BramBufferWriter is

    constant DATA_WIDTH_C : natural := PACKING_G * SAMPLE_DATA_WIDTH_G;

    type StateType is (
            IDLE_S,
            RECEIVING_S
        );

    type WriteEnableArray is array (natural range <>) of STD_LOGIC_VECTOR(DATA_WIDTH_C/BYTE_WIDTH_G-1 downto 0);

    type RegType is record
        state               : StateType;
        tready              : STD_LOGIC;
        addressCounter      : natural range 0 to NUM_ADDRESSES_G-1;
        bufferIndex         : natural range 0 to 1;
        previousBufferIndex : natural range 0 to 1;
        rowCounter          : natural range 0 to PACKING_G;
        we                  : WriteEnableArray(0 to 1);
        wrAddr              : STD_LOGIC_VECTOR(ADDR_WIDTH_G-1 downto 0);
        wrData              : STD_LOGIC_VECTOR(DATA_WIDTH_C-1 downto 0);
    end record RegType;

    constant REG_TYPE_INIT_C : RegType := (
            state               => IDLE_S,
            tready              => '0',
            addressCounter      => 0,
            bufferIndex         => 0,
            previousBufferIndex => 0,
            rowCounter          => 0,
            we                  => (others => (others => '0')),
            wrAddr              => (others => '0'),
            wrData              => (others => '0')
        );

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

        -- combinatorial logic
        case r.state is
            when IDLE_S =>
                v.tready := '1';
                v.state  := RECEIVING_S;

            when RECEIVING_S =>
                if (axisWriteSrc_i.tvalid = '1') then
                    v.wrAddr := STD_LOGIC_VECTOR(to_unsigned(r.addressCounter, ADDR_WIDTH_G));
                    v.wrData := r.wrData(SAMPLE_DATA_WIDTH_G*(PACKING_G-1)-1 downto 0) & axisWriteSrc_i.tdata(SAMPLE_DATA_WIDTH_G-1 downto 0);

                    if (r.rowCounter = PACKING_G-1) then
                        v.we(r.bufferIndex)   := (others => '1');
                        v.previousBufferIndex := r.bufferIndex;

                        if (r.addressCounter = NUM_ADDRESSES_G-1) then
                            v.bufferIndex    := getOtherBufferIndex(r.bufferIndex);
                            v.addressCounter := 0;
                        else
                            v.addressCounter := r.addressCounter + 1;
                        end if;
                        v.rowCounter := 0;
                    else
                        v.rowCounter := r.rowCounter + 1;
                    end if;

                    if (r.bufferIndex /= r.previousBufferIndex) then
                        v.we(r.previousBufferIndex) := (others => '0');
                    end if;
                else
                    v.we(r.previousBufferIndex) := (others => '0');
                end if;
            when others =>
                v := REG_TYPE_INIT_C;
        end case;
        if (rst_i = '1') then
            v := REG_TYPE_INIT_C;
        end if;

        rin <= v;

        -- Drive outputs
        axisWriteDst_o.tready <= r.tready;
        bramWriteSrc0_o.en    <= '1';
        bramWriteSrc0_o.we    <= r.we(0);
        bramWriteSrc0_o.addr  <= r.wrAddr;
        bramWriteSrc0_o.din   <= r.wrData;
        bramWriteSrc1_o.en    <= '1';
        bramWriteSrc1_o.we    <= r.we(1);
        bramWriteSrc1_o.addr  <= r.wrAddr;
        bramWriteSrc1_o.din   <= r.wrData;
        writingInto_o         <= r.previousBufferIndex;
    end process p_Comb;

    p_Seq : process(clk_i)
    begin
        if rising_edge(clk_i) then
            r <= rin;
        end if;
    end process p_Seq;

end Behavioral;
