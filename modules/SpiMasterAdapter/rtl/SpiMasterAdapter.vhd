----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/31/2025 12:16:11 PM
-- Design Name: 
-- Module Name: SpiAdapter - Behavioral
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

--use work.SpiAdapterPkg.all;

entity SpiMasterAdapter is
    Generic (
        DATA_WIDTH_G    : natural := 10;
        N_CYCLES_IDLE_G : natural := 1
    );
    Port (
        clk_i : in STD_LOGIC;
        rst_i : in STD_LOGIC;

        -- SPI interface
        miso_i : in  STD_LOGIC;
        mosi_o : out STD_LOGIC;
        cs_o   : out STD_LOGIC;

        -- Write interface
        writeData_i  : in  STD_LOGIC_VECTOR(DATA_WIDTH_G-1 downto 0);
        writeValid_i : in  STD_LOGIC;
        writeReady_o : out STD_LOGIC;

        -- Read interface
        readData_o  : out STD_LOGIC_VECTOR(DATA_WIDTH_G-1 downto 0);
        readValid_o : out STD_LOGIC;
        readReady_i : in  STD_LOGIC
    );
end SpiMasterAdapter;

architecture Behavioral of SpiMasterAdapter is

    type StateType is (
            IDLE_S,
            TRANSFER_S,
            DEASSERT_S
        );

    type RegType is record
        state           : StateType;
        writeReady      : STD_LOGIC;
        transferCounter : integer range 0 to DATA_WIDTH_G;
        writeBuffer     : STD_LOGIC_VECTOR(DATA_WIDTH_G-1 downto 0);
        mosi            : STD_LOGIC;
        cs              : STD_LOGIC;
        waitCounter     : integer range 0 to N_CYCLES_IDLE_G;
    end record RegType;

    constant REG_TYPE_INIT_C : RegType := (
            state           => IDLE_S,
            writeReady      => '0',
            transferCounter => 0,
            writeBuffer     => (others => '0'),
            mosi            => '0',
            cs              => '1',
            waitCounter     => 0
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
                v.cs         := '1';
                v.writeReady := '1';
                if (writeValid_i = '1') then
                    v.writeBuffer := writeData_i;
                    v.state       := TRANSFER_S;
                end if;

            when TRANSFER_S =>
                v.cs         := '0';
                v.writeReady := '0';
                v.mosi       := r.writeBuffer(DATA_WIDTH_G - 1 - r.transferCounter); -- MSb

                if (r.transferCounter = DATA_WIDTH_G-1) then
                    v.transferCounter := 0;
                    if (N_CYCLES_IDLE_G = 0) then
                        v.state := IDLE_S;
                    else
                        v.state := DEASSERT_S;
                    end if;
                else
                    v.transferCounter := r.transferCounter + 1;
                end if;

            when DEASSERT_S =>
                v.cs := '1';
                if (r.waitCounter = N_CYCLES_IDLE_G-1) then
                    v.waitCounter := 0;
                    v.state       := IDLE_S;
                else
                    v.waitCounter := r.waitCounter + 1;
                end if;


            when others =>
                v := REG_TYPE_INIT_C;
        end case;

        if (rst_i = '1') then
            v := REG_TYPE_INIT_C;
        end if;

        rin <= v;

        -- Drive outputs
        mosi_o       <= r.mosi;
        cs_o         <= r.cs;
        writeReady_o <= rin.writeReady;
        readData_o   <= (others => '0'); -- TODO
        readValid_o  <= '0';             -- TODO
    end process p_Comb;

    p_Seq : process(clk_i)
    begin
        if rising_edge(clk_i) then
            r <= rin;
        end if;
    end process p_Seq;
end Behavioral;
