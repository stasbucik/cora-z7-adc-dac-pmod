----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/31/2025 10:10:56 AM
-- Design Name: 
-- Module Name: Axi4Interface - Behavioral
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

entity Axi4Interface is
    generic(
        MARK_DEBUG_G        : string  := "false";
        PACKING_G           : natural := 2;
        SAMPLE_DATA_WIDTH_G : natural := 12;
        DATA_WIDTH_G        : natural := PACKING_G * SAMPLE_DATA_WIDTH_G;
        MAX_LENGTH_G        : natural := 256;
        LENGTH_WIDTH_G      : natural := natural(ceil(log2(real(MAX_LENGTH_G))));
        ADDR_WIDTH_G        : natural := natural(ceil(log2(real(1024))))
    );
    Port (
        clk_i : in STD_LOGIC;
        rst_i : in STD_LOGIC;

        axiReadSrc_i : in  Axi4ReadSource;
        axiReadDst_o : out Axi4ReadDestination;

        readStart_o : out STD_LOGIC;
        address_o   : out STD_LOGIC_VECTOR(ADDR_WIDTH_G-1 downto 0);
        length_o    : out STD_LOGIC_VECTOR(LENGTH_WIDTH_G-1 downto 0);

        readDone_i : in STD_LOGIC;
        counter_i  : in unsigned(LENGTH_WIDTH_G-1 downto 0);
        buffer_i   : in TmpBufferArray(MAX_LENGTH_G-1 downto 0)(DATA_WIDTH_G-1 downto 0)

    );
end Axi4Interface;

architecture Behavioral of Axi4Interface is

    constant FILL_C : STD_LOGIC_VECTOR(axiReadDst_o.rdata'length - DATA_WIDTH_G - 1 downto 0) := (others => '0');

    constant AXI_RESP_OK_C         : STD_LOGIC_VECTOR(1 downto 0) := "00";
    constant AXI_RESP_SLVERR_C     : STD_LOGIC_VECTOR(1 downto 0) := "10";
    constant AXI_BURST_SIZE_32_C   : STD_LOGIC_VECTOR(2 downto 0) := "101";
    constant AXI_BURST_TYPE_INCR_C : STD_LOGIC_VECTOR(1 downto 0) := "01";

    type StateType is (
            INIT_S,
            AR_HANDSHAKE_S,
            WAIT_FOR_DATA_S,
            R_HANDSHAKE_GOOD_S,
            R_HANDSHAKE_ERR_S
        );

    type RegType is record
        state           : StateType;
        addr            : STD_LOGIC_VECTOR(ADDR_WIDTH_G-1 downto 0);
        burst_len       : unsigned(axiReadSrc_i.ARLEN'range);
        burst_width     : STD_LOGIC_VECTOR(axiReadSrc_i.ARSIZE'range);
        burst_type      : STD_LOGIC_VECTOR(axiReadSrc_i.ARBURST'range);
        transferCounter : unsigned(axiReadSrc_i.ARLEN'range);
        arready         : STD_LOGIC;
        rid             : STD_LOGIC_VECTOR(axiReadDst_o.rid'range);
        rdata           : STD_LOGIC_VECTOR(axiReadDst_o.rdata'range);
        rresp           : STD_LOGIC_VECTOR(axiReadDst_o.rresp'range);
        rlast           : STD_LOGIC;
        ruser           : STD_LOGIC_VECTOR(axiReadDst_o.ruser'range);
        rvalid          : STD_LOGIC;
        readStart       : STD_LOGIC;
    end record RegType;

    constant REG_TYPE_INIT_C : RegType := (
            state           => INIT_S,
            addr            => (others => '0'),
            burst_len       => (others => '0'),
            burst_width     => (others => '0'),
            burst_type      => (others => '0'),
            transferCounter => (others => '0'),
            arready         => '0',
            rid             => (others => '0'),
            rdata           => (others => '0'),
            rresp           => (others => '0'),
            rlast           => '0',
            ruser           => (others => '0'),
            rvalid          => '0',
            readStart       => '0'
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

        v.readStart := '0';

        -- combinatorial logic
        case r.state is
            when INIT_S =>
                v.arready := '1';
                v.state   := AR_HANDSHAKE_S;

            when AR_HANDSHAKE_S =>
                if (axiReadSrc_i.arvalid = '1') then
                    v.arready := '0';

                    if (axiReadSrc_i.arburst = AXI_BURST_TYPE_INCR_C and
                            axiReadSrc_i.arsize = AXI_BURST_SIZE_32_C) then

                        v.addr        := axiReadSrc_i.araddr(ADDR_WIDTH_G-1 downto 0);
                        v.burst_len   := unsigned(axiReadSrc_i.arlen);
                        v.burst_width := axiReadSrc_i.arsize;
                        v.burst_type  := axiReadSrc_i.arburst;
                        v.readStart   := '1';
                        v.state       := WAIT_FOR_DATA_S;
                    else
                        v.rdata  := (others => '0');
                        v.rresp  := AXI_RESP_SLVERR_C;
                        v.rvalid := '1';
                        v.rlast  := '1';
                        v.state  := R_HANDSHAKE_ERR_S;
                    end if;

                end if;

            when WAIT_FOR_DATA_S =>
                if (counter_i > 0) then
                    v.rdata  := FILL_C & buffer_i(0);
                    v.rresp  := AXI_RESP_OK_C; --okay
                    v.rvalid := '1';

                    if (r.transferCounter = r.burst_len) then
                        v.rlast := '1';
                    end if;

                    v.state := R_HANDSHAKE_GOOD_S;
                end if;

            when R_HANDSHAKE_GOOD_S =>
                if (axiReadSrc_i.rready = '1') then
                    if (r.transferCounter < r.burst_len) then
                        v.transferCounter := r.transferCounter + 1;
                        v.rdata           := FILL_C & buffer_i(to_integer(r.transferCounter) + 1);
                        v.rresp           := (others => '0'); --okay
                        v.rvalid          := '1';

                        if (r.transferCounter = r.burst_len - 1) then
                            v.rlast := '1';
                        end if;
                    else
                        v.rvalid          := '0';
                        v.rlast           := '0';
                        v.rdata           := (others => '0');
                        v.transferCounter := (others => '0');
                        v.arready         := '1';
                        v.state           := AR_HANDSHAKE_S;
                    end if;
                end if;

            when R_HANDSHAKE_ERR_S =>
                if (axiReadSrc_i.rready = '1') then
                    v.rresp   := AXI_RESP_OK_C;
                    v.rvalid  := '0';
                    v.rlast   := '0';
                    v.arready := '1';
                    v.state   := AR_HANDSHAKE_S;
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
        axiReadDst_o.rid     <= r.rid;
        axiReadDst_o.rdata   <= r.rdata;
        axiReadDst_o.rresp   <= r.rresp;
        axiReadDst_o.rlast   <= r.rlast;
        axiReadDst_o.ruser   <= r.ruser;
        axiReadDst_o.rvalid  <= r.rvalid;

        readStart_o <= rin.readStart;
        address_o   <= rin.addr;
        length_o    <= STD_LOGIC_VECTOR(rin.burst_len);

    end process p_Comb;

    p_Seq : process(clk_i)
    begin
        if rising_edge(clk_i) then
            r <= rin;
        end if;
    end process p_Seq;

end Behavioral;
