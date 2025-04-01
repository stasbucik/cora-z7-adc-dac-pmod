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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DataGenerator is
    Generic(
        MAX_VAL_G    : natural := 1024;
        MIN_VAL_G    : natural := 0;
        DATA_WIDTH_G : natural := 10
    );
    Port (
        clk_i   : in  STD_LOGIC;
        rst_i   : in  STD_LOGIC;
        data_o  : out STD_LOGIC_VECTOR(DATA_WIDTH_G-1 downto 0);
        valid_o : out STD_LOGIC;
        ready_i : in  STD_LOGIC
    );
end DataGenerator;

architecture Behavioral of DataGenerator is

    type StateType is (
            ADVANCE_S,
            HANDSHAKE_S
        );

    type RegType is record
        counter : unsigned(DATA_WIDTH_G-1 downto 0);
        state   : StateType;
        valid   : STD_LOGIC;
        upDown  : STD_LOGIC;
    end record RegType;

    constant REG_TYPE_INIT_C : RegType := (
            counter => to_unsigned(MIN_VAL_G, DATA_WIDTH_G),
            state   => ADVANCE_S,
            valid   => '0',
            upDown  => '0'
        );

    signal r   : RegType;
    signal rin : RegType;

begin
    p_Comb     : process (all)
        variable v : RegType;
    begin
        v := r;

        case r.state is
            when ADVANCE_S =>
                if (r.upDown = '0') then
                    if (r.counter = MAX_VAL_G-1) then
                        v.upDown  := '1';
                        v.counter := r.counter - 1;
                    else
                        v.counter := r.counter + 1;
                    end if;
                else
                    if (r.counter = MIN_VAL_G) then
                        v.upDown  := '0';
                        v.counter := r.counter + 1;
                    else
                        v.counter := r.counter - 1;
                    end if;
                end if;

                v.valid := '1';
                v.state := HANDSHAKE_S;

            when HANDSHAKE_S =>
                if (ready_i = '1') then
                    v.valid := '0';
                    v.state := ADVANCE_S;
                end if;

            when others =>
                v := REG_TYPE_INIT_C;
        end case;

        if (rst_i = '1') then
            v := REG_TYPE_INIT_C;
        end if;

        rin <= v;

        valid_o <= r.valid;
        data_o  <= std_logic_vector(r.counter);
    end process p_Comb;

    p_Seq : process (clk_i)
    begin
        if rising_edge(clk_i) then
            r <= rin;
        end if;
    end process p_Seq;

end Behavioral;
