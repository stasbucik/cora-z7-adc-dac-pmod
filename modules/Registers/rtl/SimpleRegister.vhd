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