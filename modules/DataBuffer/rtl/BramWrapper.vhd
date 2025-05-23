----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Stas Bucik
-- 
-- Create Date: 03/31/2025 10:10:56 AM
-- Design Name: 
-- Module Name: BramWrapper - Behavioral
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

Library xpm;
use xpm.vcomponents.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity BramWrapper is
    Generic (
        MEMORY_SIZE_G : natural := 2048;
        ADDR_WIDTH_G  : natural := 8;
        BYTE_WIDTH_G  : natural := 4;
        DATA_WIDTH_G  : natural := 16;
        LATENCY_G     : natural := 1
    );
    Port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        -- Write port
        ena   : in STD_LOGIC;
        wea   : in STD_LOGIC_VECTOR(DATA_WIDTH_G/BYTE_WIDTH_G-1 downto 0);
        addra : in STD_LOGIC_VECTOR(ADDR_WIDTH_G-1 downto 0);
        dina  : in STD_LOGIC_VECTOR(DATA_WIDTH_G-1 downto 0);

        -- Read port
        enb   : in  STD_LOGIC;
        addrb : in  STD_LOGIC_VECTOR(ADDR_WIDTH_G-1 downto 0);
        doutb : out STD_LOGIC_VECTOR(DATA_WIDTH_G-1 downto 0)
    );
end BramWrapper;

architecture Behavioral of BramWrapper is
begin

    u_xpm_memory_sdpram : xpm_memory_sdpram
        generic map (
            ADDR_WIDTH_A            => ADDR_WIDTH_G,    -- DECIMAL
            ADDR_WIDTH_B            => ADDR_WIDTH_G,    -- DECIMAL
            AUTO_SLEEP_TIME         => 0,               -- DECIMAL
            BYTE_WRITE_WIDTH_A      => BYTE_WIDTH_G,    -- DECIMAL
            CASCADE_HEIGHT          => 0,               -- DECIMAL
            CLOCKING_MODE           => "common_clock",  -- String
            ECC_BIT_RANGE           => "7:0",           -- String
            ECC_MODE                => "no_ecc",        -- String
            ECC_TYPE                => "none",          -- String
            IGNORE_INIT_SYNTH       => 0,               -- DECIMAL
            MEMORY_INIT_FILE        => "none",          -- String
            MEMORY_INIT_PARAM       => "0",             -- String
            MEMORY_OPTIMIZATION     => "true",          -- String
            MEMORY_PRIMITIVE        => "block",         -- String
            MEMORY_SIZE             => MEMORY_SIZE_G,   -- DECIMAL
            MESSAGE_CONTROL         => 0,               -- DECIMAL
            RAM_DECOMP              => "auto",          -- String
            READ_DATA_WIDTH_B       => DATA_WIDTH_G,    -- DECIMAL
            READ_LATENCY_B          => LATENCY_G,       -- DECIMAL
            READ_RESET_VALUE_B      => "00000000",      -- String
            RST_MODE_A              => "SYNC",          -- String
            RST_MODE_B              => "SYNC",          -- String
            SIM_ASSERT_CHK          => 1,               -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
            USE_EMBEDDED_CONSTRAINT => 0,               -- DECIMAL
            USE_MEM_INIT            => 1,               -- DECIMAL
            USE_MEM_INIT_MMI        => 0,               -- DECIMAL
            WAKEUP_TIME             => "disable_sleep", -- String
            WRITE_DATA_WIDTH_A      => DATA_WIDTH_G,    -- DECIMAL
            WRITE_MODE_B            => "no_change",     -- String
            WRITE_PROTECT           => 1                -- DECIMAL
        )
        port map (
            dbiterrb => open, -- 1-bit output: Status signal to indicate double bit error occurrence
                              -- on the data output of port B.

            doutb    => doutb, -- READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
            sbiterrb => open,  -- 1-bit output: Status signal to indicate single bit error occurrence
                               -- on the data output of port B.

            addra => addra, -- ADDR_WIDTH_A-bit input: Address for port A write operations.
            addrb => addrb, -- ADDR_WIDTH_B-bit input: Address for port B read operations.
            clka  => clk,   -- 1-bit input: Clock signal for port A. Also clocks port B when
                            -- parameter CLOCKING_MODE is "common_clock".

            clkb => clk, -- 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is
                         -- "independent_clock". Unused when parameter CLOCKING_MODE is
                         -- "common_clock".

            dina => dina, -- WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
            ena  => ena,  -- 1-bit input: Memory enable signal for port A. Must be high on clock
                          -- cycles when write operations are initiated. Pipelined internally.

            enb => enb, -- 1-bit input: Memory enable signal for port B. Must be high on clock
                        -- cycles when read operations are initiated. Pipelined internally.

            injectdbiterra => '0', -- 1-bit input: Controls double bit error injection on input data when
                                   -- ECC enabled (Error injection capability is not available in
                                   -- "decode_only" mode).

            injectsbiterra => '0', -- 1-bit input: Controls single bit error injection on input data when
                                   -- ECC enabled (Error injection capability is not available in
                                   -- "decode_only" mode).

            regceb => '1', -- 1-bit input: Clock Enable for the last register stage on the output
                           -- data path.

            rstb => rst, -- 1-bit input: Reset signal for the final port B output register
                         -- stage. Synchronously resets output port doutb to the value specified
                         -- by parameter READ_RESET_VALUE_B.

            sleep => '0', -- 1-bit input: sleep signal to enable the dynamic power saving feature.
            wea   => wea  -- WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector
                          -- for port A input data port dina. 1 bit wide when word-wide writes
                          -- are used. In byte-wide write configurations, each bit controls the
                          -- writing one byte of dina to address addra. For example, to
                          -- synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A
                          -- is 32, wea would be 4'b0010.

        );

end Behavioral;
