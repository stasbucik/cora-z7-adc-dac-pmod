----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Stas Bucik
-- 
-- Create Date: 03/31/2025 10:10:56 AM
-- Design Name: 
-- Module Name: StatRegAxi4Iface - Behavioral
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
use work.UnsignedOpsPkg.all;

use IEEE.math_real."ceil";
use IEEE.math_real."log2";

entity StatRegAxi4Iface is
    generic(
        MARK_DEBUG_G  : string                := "false";
        WIDTH_G       : positive              := 32;
        AXI_ADDRESS_G : unsigned(31 downto 0) := x"8000_0000"
    );
    Port (
        clk_i : in STD_LOGIC;
        rst_i : in STD_LOGIC;

        axiReadSrc_i : in  Axi4ReadSource;
        axiReadDst_o : out Axi4ReadDestination;

        data_i        : in  STD_LOGIC_VECTOR(WIDTH_G-1 downto 0)

    );
end StatRegAxi4Iface;

architecture Behavioral of StatRegAxi4Iface is

    constant AXI_RESP_OK_C            : STD_LOGIC_VECTOR(1 downto 0) := "00";
    constant AXI_RESP_SLVERR_C        : STD_LOGIC_VECTOR(1 downto 0) := "10";
    constant AXI_BURST_SIZE_4_BYTES_C : STD_LOGIC_VECTOR(2 downto 0) := "010";

    type StateType is (
            INIT_S,
            INITAL_ADDR_HANDSHAKE_S,
            R_HANDSHAKE_GOOD_S,
            R_HANDSHAKE_ERR_S
        );

    type RegType is record
        state           : StateType;
        burst_len       : unsigned(axiReadSrc_i.ARLEN'range);
        transferCounter : unsigned(axiReadSrc_i.ARLEN'length downto 0); -- one more bit to prevent overflow
        arready         : STD_LOGIC;
        rdata           : STD_LOGIC_VECTOR(axiReadDst_o.rdata'range);
        rresp           : STD_LOGIC_VECTOR(axiReadDst_o.rresp'range);
        rlast           : STD_LOGIC;
        rvalid          : STD_LOGIC;
    end record RegType;

    constant REG_TYPE_INIT_C : RegType := (
            state           => INIT_S,
            burst_len       => (others => '0'),
            transferCounter => (others => '0'),
            arready         => '0',
            rdata           => (others => '0'),
            rresp           => (others => '0'),
            rlast           => '0',
            rvalid          => '0'
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

        -- combinatorial logic
        case r.state is
            when INIT_S =>
                v.arready := '1';
                v.state   := INITAL_ADDR_HANDSHAKE_S;

            when INITAL_ADDR_HANDSHAKE_S =>
                if (axiReadSrc_i.arvalid = '1') then
                    -- we are going to do a read
                    v.arready   := '0';
                    v.burst_len := unsigned(axiReadSrc_i.arlen);

                    if (axiReadSrc_i.arlen = x"00" and axiReadSrc_i.arsize = AXI_BURST_SIZE_4_BYTES_C) then

                        v.rdata  := data_i;
                        v.rresp  := AXI_RESP_OK_C; --okay
                        v.rvalid := '1';
                        v.rlast  := '1';
                        v.state  := R_HANDSHAKE_GOOD_S;
                    else
                        v.rdata           := (others => '0');
                        v.rresp           := AXI_RESP_SLVERR_C;
                        v.rvalid          := '1';
                        v.transferCounter := r.transferCounter + 1;
                        if (uEq(r.transferCounter, unsigned(axiReadSrc_i.arlen))) then
                            v.rlast := '1';
                        end if;
                        v.state := R_HANDSHAKE_ERR_S;
                    end if;
                end if;

            when R_HANDSHAKE_GOOD_S =>
                if (axiReadSrc_i.rready = '1') then
                    --burst completed
                    v.rvalid  := '0';
                    v.rlast   := '0';
                    v.rdata   := (others => '0');
                    v.arready := '1';
                    v.state   := INITAL_ADDR_HANDSHAKE_S;
                end if;

            when R_HANDSHAKE_ERR_S =>
                if (axiReadSrc_i.rready = '1') then
                    if (uLeq(r.transferCounter, r.burst_len)) then
                        v.rdata           := (others => '0');
                        v.rresp           := AXI_RESP_SLVERR_C;
                        v.rvalid          := '1';
                        v.transferCounter := r.transferCounter + 1;
                        if (uEq(r.transferCounter, r.burst_len)) then
                            v.rlast := '1';
                        end if;
                    else
                        v.rresp           := AXI_RESP_OK_C;
                        v.rvalid          := '0';
                        v.rlast           := '0';
                        v.arready         := '1';
                        v.transferCounter := (others => '0');
                        v.state           := INITAL_ADDR_HANDSHAKE_S;
                    end if;
                end if;

            when others =>
                v := REG_TYPE_INIT_C;

        end case;

        if (rst_i = '1') then
            v := REG_TYPE_INIT_C;
        end if;

        rin <= v;

        -- Drive outputs
        axiReadDst_o.arready <= r.arready;
        axiReadDst_o.rid     <= (others => '0');
        axiReadDst_o.rdata   <= r.rdata;
        axiReadDst_o.rresp   <= r.rresp;
        axiReadDst_o.rlast   <= r.rlast;
        axiReadDst_o.ruser   <= (others => '0');
        axiReadDst_o.rvalid  <= r.rvalid;

    end process p_Comb;

    p_Seq : process(clk_i)
    begin
        if rising_edge(clk_i) then
            r <= rin;
        end if;
    end process p_Seq;

end Behavioral;
