----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/31/2025 10:10:56 AM
-- Design Name: 
-- Module Name: DataGenerator - Behavioral
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
use work.Axi4Pkg.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DataGenerator is
    Generic(
        MAX_VAL_G : natural := 1024;
        MIN_VAL_G : natural := 0
    );
    Port (
        clk_i     : in  STD_LOGIC;
        rst_i     : in  STD_LOGIC;
        axisSrc_o : out Axi4StreamSource;
        axisDst_i : in  Axi4StreamDestination
    );
end DataGenerator;

architecture Behavioral of DataGenerator is

    type StateType is (
            IDLE_S,
            ADVANCE_S
        );

    type RegType is record
        state        : StateType;
        axiSrcDriver : axisSrc_o'subtype;
        upDown       : STD_LOGIC;
    end record RegType;

    constant AXI_4_STREAM_SRC_INIT_C : axisSrc_o'subtype := (
            TVALID  => '0',
            TDATA   => (others => '0'),
            TSTRB   => (others => '1'),
            TKEEP   => (others => '1'),
            TLAST   => '0',
            TID     => (others => '0'),
            TDEST   => (others => '0'),
            TUSER   => (others => '0'),
            TWAKEUP => '0'
        );

    constant REG_TYPE_INIT_C : RegType := (
            state        => IDLE_S,
            axiSrcDriver => AXI_4_STREAM_SRC_INIT_C,
            upDown       => '0'
        );
    signal r   : RegType;
    signal rin : RegType;

begin
    p_Comb     : process (all)
        variable v : RegType;
    begin
        v := r;

        case r.state is
            when IDLE_S =>
                v.axiSrcDriver.tdata  := STD_LOGIC_VECTOR(to_unsigned(MIN_VAL_G, r.axiSrcDriver.tdata'length));
                v.axiSrcDriver.tvalid := '1';
                v.state               := ADVANCE_S;
            when ADVANCE_S =>
                if (axisDst_i.tready = '1') then
                    if (r.upDown = '0') then
                        if (to_integer(unsigned(r.axiSrcDriver.tdata)) = MAX_VAL_G-1) then
                            v.upDown             := '1';
                            v.axiSrcDriver.tdata := STD_LOGIC_VECTOR(unsigned(r.axiSrcDriver.tdata) - 1);
                        else
                            v.axiSrcDriver.tdata := STD_LOGIC_VECTOR(unsigned(r.axiSrcDriver.tdata) + 1);
                        end if;
                    else
                        if (to_integer(unsigned(r.axiSrcDriver.tdata)) = MIN_VAL_G) then
                            v.upDown             := '0';
                            v.axiSrcDriver.tdata := STD_LOGIC_VECTOR(unsigned(r.axiSrcDriver.tdata) + 1);
                        else
                            v.axiSrcDriver.tdata := STD_LOGIC_VECTOR(unsigned(r.axiSrcDriver.tdata) - 1);
                        end if;
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
        axisSrc_o.tvalid  <= r.axiSrcDriver.tvalid;
        axisSrc_o.tdata   <= r.axiSrcDriver.tdata;
        axisSrc_o.tstrb   <= r.axiSrcDriver.tstrb;
        axisSrc_o.tkeep   <= r.axiSrcDriver.tkeep;
        axisSrc_o.tlast   <= r.axiSrcDriver.tlast;
        axisSrc_o.tid     <= r.axiSrcDriver.tid;
        axisSrc_o.tdest   <= r.axiSrcDriver.tdest;
        axisSrc_o.tuser   <= r.axiSrcDriver.tuser;
        axisSrc_o.twakeup <= r.axiSrcDriver.twakeup;
    end process p_Comb;

    p_Seq : process (clk_i)
    begin
        if rising_edge(clk_i) then
            r <= rin;
        end if;
    end process p_Seq;

end Behavioral;
