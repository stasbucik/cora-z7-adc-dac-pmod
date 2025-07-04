----------------------------------------------------------------------------------
--  Copyright 2025, University of Ljubljana
--
--  This file is part of cora-z7-adc-dac-pmod.
--  cora-z7-adc-dac-pmod is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by the Free Software Foundation,
--  either version 3 of the License, or any later version.
--  cora-z7-adc-dac-pmod is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
--  FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
--  You should have received a copy of the GNU General Public License along with cora-z7-adc-dac-pmod.
--  If not, see <https://www.gnu.org/licenses/>. 
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

entity BufferAxi4Iface is
    generic(
        MARK_DEBUG_G        : string                := "false";
        PACKING_G           : natural               := 2;
        SAMPLE_DATA_WIDTH_G : natural               := 12;
        DATA_WIDTH_G        : natural               := PACKING_G * SAMPLE_DATA_WIDTH_G;
        MAX_LENGTH_G        : natural               := 16;
        LENGTH_WIDTH_G      : natural               := natural(ceil(log2(real(MAX_LENGTH_G))));
        ADDR_WIDTH_G        : natural               := natural(ceil(log2(real(1024))));
        AXI_ADDRESS_G       : unsigned(31 downto 0) := x"8000_0000"
    );
    Port (
        clk_i : in STD_LOGIC;
        rst_i : in STD_LOGIC;

        axiReadSrc_i : in  Axi4ReadSource;
        axiReadDst_o : out Axi4ReadDestination;

        readStart_o : out STD_LOGIC;
        address_o   : out STD_LOGIC_VECTOR(ADDR_WIDTH_G-1 downto 0);
        length_o    : out STD_LOGIC_VECTOR(LENGTH_WIDTH_G-1 downto 0);

        firstReady_i : in STD_LOGIC;
        buffer_i     : in TmpBufferArray(MAX_LENGTH_G-1 downto 0)(DATA_WIDTH_G-1 downto 0)

    );
end BufferAxi4Iface;

architecture Behavioral of BufferAxi4Iface is

    constant FILL_C : STD_LOGIC_VECTOR(axiReadDst_o.rdata'length - DATA_WIDTH_G - 1 downto 0) := (others => '0');

    constant AXI_RESP_OK_C            : STD_LOGIC_VECTOR(1 downto 0) := "00";
    constant AXI_RESP_SLVERR_C        : STD_LOGIC_VECTOR(1 downto 0) := "10";
    constant AXI_BURST_SIZE_4_BYTES_C : STD_LOGIC_VECTOR(2 downto 0) := "010";
    constant AXI_BURST_TYPE_INCR_C    : STD_LOGIC_VECTOR(1 downto 0) := "01";

    type StateType is (
            INIT_S,
            AR_HANDSHAKE_S,
            WAIT_FOR_DATA_S,
            R_HANDSHAKE_GOOD_S,
            R_HANDSHAKE_ERR_S
        );

    type RegType is record
        state     : StateType;
        addr      : STD_LOGIC_VECTOR(ADDR_WIDTH_G-1 downto 0);
        axiAddr   : STD_LOGIC_VECTOR(axiReadSrc_i.araddr'range);
        burst_len : unsigned(axiReadSrc_i.ARLEN'range);
        read_len  : unsigned(LENGTH_WIDTH_G-1 downto 0);
        -- total addresses read
        totalTransferCounter : unsigned(axiReadSrc_i.ARLEN'length downto 0); -- one more bit to prevent overflow
                                                                             -- addresses read for one burst
        subTransferCounter : unsigned(LENGTH_WIDTH_G downto 0);              -- one more bit to prevent overflow
        arready            : STD_LOGIC; rdata : STD_LOGIC_VECTOR(axiReadDst_o.rdata'range);
        rresp              : STD_LOGIC_VECTOR(axiReadDst_o.rresp'range);
        rlast              : STD_LOGIC;
        rvalid             : STD_LOGIC;
        readStart          : STD_LOGIC;
    end record RegType;

    constant REG_TYPE_INIT_C : RegType := (
            state                => INIT_S,
            addr                 => (others => '0'),
            axiAddr              => (others => '0'),
            burst_len            => (others => '0'),
            read_len             => (others => '0'),
            totalTransferCounter => (others => '0'),
            subTransferCounter   => (others => '0'),
            arready              => '0',
            rdata                => (others => '0'),
            rresp                => (others => '0'),
            rlast                => '0',
            rvalid               => '0',
            readStart            => '0'
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
                    -- capture burst length
                    v.burst_len := unsigned(axiReadSrc_i.arlen);

                    if (axiReadSrc_i.arburst = AXI_BURST_TYPE_INCR_C and
                            axiReadSrc_i.arsize = AXI_BURST_SIZE_4_BYTES_C) then
                        -- suport only full width incremental transfers

                        -- Substract offset and divide by four
                        v.axiAddr := STD_LOGIC_VECTOR(shift_right(uSub(unsigned(axiReadSrc_i.araddr), AXI_ADDRESS_G), 2));
                        v.addr    := v.axiAddr(ADDR_WIDTH_G-1 downto 0);

                        -- Do only up to MAX_LENGTH_G transfers at once
                        if (to_integer(unsigned(axiReadSrc_i.arlen)) > MAX_LENGTH_G-1) then
                            v.read_len := to_unsigned(MAX_LENGTH_G-1, LENGTH_WIDTH_G);
                        else
                            v.read_len := unsigned(axiReadSrc_i.arlen(LENGTH_WIDTH_G-1 downto 0));
                        end if;

                        v.readStart := '1';
                        v.state     := WAIT_FOR_DATA_S;
                    else
                        -- Respond with error
                        v.rdata                := (others => '0');
                        v.rresp                := AXI_RESP_SLVERR_C;
                        v.rvalid               := '1';
                        v.totalTransferCounter := r.totalTransferCounter + 1;
                        if (uEq(r.totalTransferCounter, unsigned(axiReadSrc_i.arlen))) then
                            v.rlast := '1';
                        end if;
                        v.state := R_HANDSHAKE_ERR_S;
                    end if;

                end if;

            when WAIT_FOR_DATA_S =>
                if (firstReady_i = '1') then
                    v.rdata              := FILL_C & buffer_i(0);
                    v.rresp              := AXI_RESP_OK_C; --okay
                    v.rvalid             := '1';
                    v.subTransferCounter := r.subTransferCounter + 1;

                    if (uEq(uAdd(r.subTransferCounter, r.totalTransferCounter), r.burst_len)) then
                        v.rlast := '1';
                    end if;

                    v.state := R_HANDSHAKE_GOOD_S;
                end if;

            when R_HANDSHAKE_GOOD_S =>
                if (axiReadSrc_i.rready = '1') then
                    if (uLeq(uAdd(r.subTransferCounter, r.totalTransferCounter), r.burst_len)) then
                        -- the burst is not completed

                        if (uLeq(r.subTransferCounter, r.read_len)) then
                            -- we have enough data from bram
                            v.subTransferCounter := r.subTransferCounter + 1;
                            v.rdata              := FILL_C & buffer_i(to_integer(r.subTransferCounter));
                            v.rresp              := AXI_RESP_OK_C;
                            v.rvalid             := '1';
                        else
                            -- new read from bram must begin
                            v.rvalid := '0';
                            if (uSub(r.burst_len, uAdd(r.subTransferCounter, r.totalTransferCounter)) > MAX_LENGTH_G-1) then
                                v.read_len := to_unsigned(MAX_LENGTH_G-1, LENGTH_WIDTH_G);
                            else
                                v.read_len := uSub(r.burst_len, uAdd(r.subTransferCounter, r.totalTransferCounter))(LENGTH_WIDTH_G-1 downto 0);
                            end if;
                            v.addr                 := STD_LOGIC_VECTOR(uAdd(unsigned(r.addr), r.subTransferCounter));
                            v.readStart            := '1';
                            v.subTransferCounter   := (others => '0');
                            v.totalTransferCounter := uAdd(r.totalTransferCounter, r.subTransferCounter);
                            v.state                := WAIT_FOR_DATA_S;
                        end if;

                        if (uEq(uAdd(r.subTransferCounter, r.totalTransferCounter), r.burst_len)) then
                            v.rlast := '1';
                        end if;
                    else
                        --burst completed
                        v.rvalid               := '0';
                        v.rlast                := '0';
                        v.rdata                := (others => '0');
                        v.subTransferCounter   := (others => '0');
                        v.totalTransferCounter := (others => '0');
                        v.arready              := '1';
                        v.state                := AR_HANDSHAKE_S;
                    end if;
                end if;

            when R_HANDSHAKE_ERR_S =>
                if (axiReadSrc_i.rready = '1') then
                    if (uLeq(r.totalTransferCounter, r.burst_len)) then
                        v.rdata                := (others => '0');
                        v.rresp                := AXI_RESP_SLVERR_C;
                        v.rvalid               := '1';
                        v.totalTransferCounter := r.totalTransferCounter + 1;
                        if (uEq(r.totalTransferCounter, r.burst_len)) then
                            v.rlast := '1';
                        end if;
                    else
                        v.rresp                := AXI_RESP_OK_C;
                        v.rvalid               := '0';
                        v.rlast                := '0';
                        v.totalTransferCounter := (others => '0');
                        v.arready              := '1';
                        v.state                := AR_HANDSHAKE_S;
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

        readStart_o <= r.readStart;
        address_o   <= r.addr;
        length_o    <= STD_LOGIC_VECTOR(r.read_len);

    end process p_Comb;

    p_Seq : process(clk_i)
    begin
        if rising_edge(clk_i) then
            r <= rin;
        end if;
    end process p_Seq;

end Behavioral;
