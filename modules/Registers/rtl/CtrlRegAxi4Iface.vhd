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

entity CtrlRegAxi4Iface is
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

        axiWriteSrc_i : in  Axi4WriteSource;
        axiWriteDst_o : out Axi4WriteDestination;

        writeEnable_o : out STD_LOGIC;
        data_o        : out STD_LOGIC_VECTOR(WIDTH_G-1 downto 0);
        data_i        : in  STD_LOGIC_VECTOR(WIDTH_G-1 downto 0)

    );
end CtrlRegAxi4Iface;

architecture Behavioral of CtrlRegAxi4Iface is

    constant AXI_RESP_OK_C            : STD_LOGIC_VECTOR(1 downto 0) := "00";
    constant AXI_RESP_SLVERR_C        : STD_LOGIC_VECTOR(1 downto 0) := "10";
    constant AXI_BURST_SIZE_4_BYTES_C : STD_LOGIC_VECTOR(2 downto 0) := "010";

    type StateType is (
            INIT_S,
            INITAL_ADDR_HANDSHAKE_S,
            R_HANDSHAKE_GOOD_S,
            R_HANDSHAKE_ERR_S,
            AW_HANDSHAKE_GOOD_S,
            W_HANDSHAKE_GOOD_S,
            B_HANDSHAKE_GOOD_S,
            AW_HANDSHAKE_ERR_S,
            W_HANDSHAKE_ERR_S,
            B_HANDSHAKE_ERR_S
        );

    type RegType is record
        state           : StateType;
        burst_len       : unsigned(axiReadSrc_i.ARLEN'range);
        transferCounter : unsigned(axiReadSrc_i.ARLEN'length downto 0); -- one more bit to prevent overflow
        writeData       : STD_LOGIC_VECTOR(WIDTH_G-1 downto 0);
        writeEnable     : STD_LOGIC;
        arready         : STD_LOGIC;
        rdata           : STD_LOGIC_VECTOR(axiReadDst_o.rdata'range);
        rresp           : STD_LOGIC_VECTOR(axiReadDst_o.rresp'range);
        rlast           : STD_LOGIC;
        rvalid          : STD_LOGIC;
        awready         : STD_LOGIC;
        wready          : STD_LOGIC;
        bresp           : STD_LOGIC_VECTOR(axiWriteDst_o.bresp'range);
        bvalid          : STD_LOGIC;
    end record RegType;

    constant REG_TYPE_INIT_C : RegType := (
            state           => INIT_S,
            burst_len       => (others => '0'),
            transferCounter => (others => '0'),
            writeData       => (others => '0'),
            writeEnable     => '0',
            arready         => '0',
            rdata           => (others => '0'),
            rresp           => (others => '0'),
            rlast           => '0',
            rvalid          => '0',
            awready         => '0',
            wready          => '0',
            bresp           => (others => '0'),
            bvalid          => '0'
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

        v.writeEnable := '0';

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

                elsif (axiWriteSrc_i.awvalid = '1') then
                    -- we are going to do a write
                    v.arready := '0';
                    v.awready := '1';

                    if (axiWriteSrc_i.awlen = x"00" and axiWriteSrc_i.awsize = AXI_BURST_SIZE_4_BYTES_C) then
                        v.state := AW_HANDSHAKE_GOOD_S;
                    else
                        v.state := AW_HANDSHAKE_ERR_S;
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

            when AW_HANDSHAKE_GOOD_S =>
                v.awready := '0';
                v.wready  := '1';
                v.state   := W_HANDSHAKE_GOOD_S;

            when W_HANDSHAKE_GOOD_S =>
                if (axiWriteSrc_i.wvalid = '1') then
                    --burst completed
                    v.writeData   := axiWriteSrc_i.wdata;
                    v.writeEnable := '1';
                    v.wready      := '0';
                    v.bresp       := AXI_RESP_OK_C;
                    v.bvalid      := '1';
                    v.state       := B_HANDSHAKE_GOOD_S;
                end if;

            when B_HANDSHAKE_GOOD_S =>
                if (axiWriteSrc_i.bready = '1') then
                    v.bvalid  := '0';
                    v.arready := '1';
                    v.state   := INITAL_ADDR_HANDSHAKE_S;
                end if;

            when AW_HANDSHAKE_ERR_S =>
                v.awready   := '0';
                v.wready    := '1';
                v.burst_len := unsigned(axiWriteSrc_i.awlen);
                v.state     := W_HANDSHAKE_ERR_S;

            when W_HANDSHAKE_ERR_S =>
                if (axiWriteSrc_i.wvalid = '1') then
                    if (uEq(r.transferCounter, r.burst_len)) then
                        --burst completed
                        v.wready          := '0';
                        v.bresp           := AXI_RESP_SLVERR_C;
                        v.bvalid          := '1';
                        v.transferCounter := (others => '0');
                        v.state           := B_HANDSHAKE_ERR_S;
                    else
                        v.transferCounter := r.transferCounter + 1;
                    end if;
                end if;

            when B_HANDSHAKE_ERR_S =>
                if (axiWriteSrc_i.bready = '1') then
                    v.bvalid  := '0';
                    v.arready := '1';
                    v.state   := INITAL_ADDR_HANDSHAKE_S;
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

        axiWriteDst_o.awready <= r.awready;
        axiWriteDst_o.wready  <= r.wready;
        axiWriteDst_o.bid     <= (others => '0');
        axiWriteDst_o.bresp   <= r.bresp;
        axiWriteDst_o.buser   <= (others => '0');
        axiWriteDst_o.bvalid  <= r.bvalid;

        writeEnable_o <= r.writeEnable;
        data_o        <= r.writeData;

    end process p_Comb;

    p_Seq : process(clk_i)
    begin
        if rising_edge(clk_i) then
            r <= rin;
        end if;
    end process p_Seq;

end Behavioral;
