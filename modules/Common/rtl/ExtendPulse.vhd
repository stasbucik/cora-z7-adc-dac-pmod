library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use IEEE.math_real."ceil";
use IEEE.math_real."log2";

library UNISIM;
use UNISIM.VComponents.all;

entity ExtendPulse is
    Generic (
        NUM_G : positive := 5
    );
    Port (
        clk_i : in  STD_LOGIC;
        rst_i : in  STD_LOGIC;
        sig_i : in  STD_LOGIC;
        sig_o : out STD_LOGIC
    );
end ExtendPulse;

architecture Behavioral of ExtendPulse is

    type StateType is (
            IDLE_S,
            PULSE_S
        );

    type RegType is record
        state   : StateType;
        counter : unsigned(integer(ceil(log2(real(NUM_G)))) downto 0);
        driver  : STD_LOGIC;
    end record RegType;

    constant REG_TYPE_INIT_C : RegType := (
            state   => IDLE_S,
            counter => (others => '0'),
            driver  => '0'
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
                    v.driver  := '1';
                    v.counter := r.counter + 1;
                    v.state   := PULSE_S;
                end if;

            when PULSE_S =>
                if (r.counter = NUM_G) then
                    v.driver  := '0';
                    v.counter := (others => '0');
                    v.state   := IDLE_S;
                else
                    v.counter := r.counter + 1;
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