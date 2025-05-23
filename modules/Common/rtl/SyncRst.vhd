----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Stas Bucik
-- 
-- Create Date: 
-- Design Name: 
-- Module Name: SyncRst - 
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

entity SyncRst is
    Generic (
        NUM_STAGES_G : positive := 2
    );
    Port (
        clk_i      : in  STD_LOGIC;
        asyncRst_i : in  STD_LOGIC;
        syncRst_o  : out STD_LOGIC
    );
end SyncRst;

architecture Behavioral of SyncRst is

    signal inputs  : STD_LOGIC_VECTOR(NUM_STAGES_G-1 downto 0);
    signal outputs : STD_LOGIC_VECTOR(NUM_STAGES_G-1 downto 0);
begin

    g_flipFlops : for i in 0 to NUM_STAGES_G-1 generate
        u_FDPE : FDPE
            generic map (
                INIT => '1')
            port map (
                Q   => outputs(i), -- Data output
                C   => clk_i,      -- Clock input
                CE  => '1',        -- Clock enable input
                PRE => asyncRst_i, -- Asynchronous preset input
                D   => inputs(i)   -- Data input
            );
    end generate g_flipFlops;

    inputs(0) <= '0';

    g_connections : for i in 0 to NUM_STAGES_G-2 generate
        inputs(i+1) <= outputs(i);
    end generate g_connections;

    syncRst_o <= outputs(NUM_STAGES_G-1);

end Behavioral;