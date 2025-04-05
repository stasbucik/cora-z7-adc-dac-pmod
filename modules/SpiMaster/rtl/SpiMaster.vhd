----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/31/2025 12:16:11 PM
-- Design Name: 
-- Module Name: SpiMaster - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SpiMaster is
    Generic (
        DATA_WIDTH_G    : natural := 10;
        N_CYCLES_IDLE_G : natural := 1
    );
    Port (
        clk_i   : in STD_LOGIC;
        rst_i   : in STD_LOGIC;

        -- SPI interface
        miso_i : in  STD_LOGIC;
        mosi_o : out STD_LOGIC;
        cs_o   : out STD_LOGIC

        -- Write interface
        -- axis

        -- Read interface
        -- axis
        
    );
end SpiMaster;

architecture Behavioral of SpiMaster is

    --type RegType is record
    --    
    --end record RegType;
--
    --constant REG_TYPE_INIT_C : RegType := (
    --        
    --    );

    signal r   : RegType;
    signal rin : RegType;
begin

    p_Comb     : process(all)
        variable v : RegType;
    begin
        v := r;

        -- combinatorial logic
        

        if (rst_i = '1') then
            v := REG_TYPE_INIT_C;
        end if;

        rin <= v;

        -- Drive outputs
        
    end process p_Comb;

    p_Seq : process(clk_i)
    begin
        if rising_edge(clk_i) then
            r <= rin;
        end if;
    end process p_Seq;
end Behavioral;
