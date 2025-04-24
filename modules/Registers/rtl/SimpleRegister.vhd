library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SimpleRegister is
    Generic (
        WIDTH_G : positive := 32
    );
    Port (
        clk_i       : in  STD_LOGIC;
        rst_i       : in  STD_LOGIC;
        din_i       : in  STD_LOGIC_VECTOR(WIDTH_G-1 downto 0);
        dout_o      : out STD_LOGIC_VECTOR(WIDTH_G-1 downto 0);
        writeCtrl_i : in  STD_LOGIC
    );
end SimpleRegister;

architecture Behavioral of SimpleRegister is

    type RegType is record
        data : STD_LOGIC_VECTOR(WIDTH_G-1 downto 0);
    end record RegType;

    constant REG_TYPE_INIT_C : RegType := (
            data => (others => '0')
        );

    signal r   : RegType;
    signal rin : RegType;

begin

    p_Comb     : process(all)
        variable v : RegType;
    begin
        v := r;

        -- combinatorial logic
        if (writeCtrl_i = '1') then
            v.data := din_i;
        end if;

        if (rst_i = '1') then
            v := REG_TYPE_INIT_C;
        end if;

        rin <= v;

        -- Drive outputs
        dout_o <= r.data;
    end process p_Comb;

    p_Seq : process(clk_i)
    begin
        if rising_edge(clk_i) then
            r <= rin;
        end if;
    end process p_Seq;

end Behavioral;