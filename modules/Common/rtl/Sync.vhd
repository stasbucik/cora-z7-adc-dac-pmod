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

library UNISIM;
use UNISIM.VComponents.all;

entity Sync is
    Generic (
        NUM_STAGES_G : positive := 2
    );
    Port (
        clk_i : in  STD_LOGIC;
        rst_i : in  STD_LOGIC;
        sig_i : in  STD_LOGIC;
        sig_o : out STD_LOGIC
    );
end Sync;

architecture Behavioral of Sync is

    signal inputs  : STD_LOGIC_VECTOR(NUM_STAGES_G-1 downto 0);
    signal outputs : STD_LOGIC_VECTOR(NUM_STAGES_G-1 downto 0);
begin

    g_flipFlops : for i in 0 to NUM_STAGES_G-1 generate
        u_FDPE : FDRE
            generic map (
                INIT => '1')
            port map (
                Q  => outputs(i), -- Data output
                C  => clk_i,      -- Clock input
                CE => '1',        -- Clock enable input
                R  => rst_i,      -- Synchronous reset input
                D  => inputs(i)   -- Data input
            );
    end generate g_flipFlops;

    inputs(0) <= sig_i;

    g_connections : for i in 0 to NUM_STAGES_G-2 generate
        inputs(i+1) <= outputs(i);
    end generate g_connections;

    sig_o <= outputs(NUM_STAGES_G-1);

end Behavioral;