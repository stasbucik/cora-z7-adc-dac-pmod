----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Stas Bucik
-- 
-- Create Date: 
-- Design Name: 
-- Module Name: LatchPulse - 
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

library UNISIM;
use UNISIM.VComponents.all;

entity LatchPulse is
    Port (
        clk_i : in  STD_LOGIC;
        rst_i : in  STD_LOGIC;
        sig_i : in  STD_LOGIC;
        sig_o : out STD_LOGIC;
        clr_i : in  STD_LOGIC
    );
end LatchPulse;

architecture Behavioral of LatchPulse is

    type StateType is (
            IDLE_S,
            LATCHED_S
        );

    type RegType is record
        state  : StateType;
        driver : STD_LOGIC;
    end record RegType;

    constant REG_TYPE_INIT_C : RegType := (
            state  => IDLE_S,
            driver => '0'
        );

    signal r   : RegType;
    signal rin : RegType;

begin

    p_Comb     : process(all)
        variable v : RegType;
    begin
        v := r;

        -- combinatorial logic
        case r.state is
            when IDLE_S =>
                if (sig_i = '1') then
                    v.driver := '1';
                    v.state  := LATCHED_S;
                end if;

            when LATCHED_S =>
                if (clr_i = '1') then
                    v.driver := '0';
                    v.state  := IDLE_S;
                end if;

            when others =>
                v := REG_TYPE_INIT_C;

        end case;

        if (rst_i = '1') then
            v := REG_TYPE_INIT_C;
        end if;

        rin <= v;

        -- Drive outputs
        sig_o <= rin.driver;
    end process p_Comb;

    p_Seq : process(clk_i)
    begin
        if rising_edge(clk_i) then
            r <= rin;
        end if;
    end process p_Seq;

end Behavioral;