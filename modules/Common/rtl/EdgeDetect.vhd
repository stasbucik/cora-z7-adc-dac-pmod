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

entity EdgeDetect is
    Generic (
        POSITIVE_EDGE_G : boolean := true;
        NEGATIVE_EDGE_G : boolean := true
    );
    Port (
        clk_i : in  STD_LOGIC;
        rst_i : in  STD_LOGIC;
        sig_i : in  STD_LOGIC;
        sig_o : out STD_LOGIC
    );
end EdgeDetect;

architecture Behavioral of EdgeDetect is

    type RegType is record
        prevVal : STD_LOGIC;
        driver  : STD_LOGIC;
    end record RegType;

    constant REG_TYPE_INIT_C : RegType := (
            prevVal => '0',
            driver  => '0'
        );

    signal r   : RegType;
    signal rin : RegType;

begin

    p_Comb     : process(all)
        variable v : RegType;
    begin
        v := r;

        v.driver := '0';

        -- combinatorial logic
        v.prevVal := sig_i;

        if (POSITIVE_EDGE_G) then
            if (r.prevVal = '0' and sig_i = '1') then
                v.driver := '1';
            end if;
        end if;

        if (NEGATIVE_EDGE_G) then
            if (r.prevVal = '1' and sig_i = '0') then
                v.driver := '1';
            end if;
        end if;

        if (rst_i = '1') then
            v := REG_TYPE_INIT_C;
        end if;

        rin <= v;

        -- Drive outputs
        sig_o <= r.driver;
    end process p_Comb;

    p_Seq : process(clk_i)
    begin
        if rising_edge(clk_i) then
            r <= rin;
        end if;
    end process p_Seq;

end Behavioral;