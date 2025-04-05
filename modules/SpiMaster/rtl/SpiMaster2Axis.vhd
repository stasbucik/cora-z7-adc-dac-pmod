----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/31/2025 12:16:11 PM
-- Design Name: 
-- Module Name: SpiMaster2Axis - Behavioral
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

use work.SpiAdapterPkg.all;
use work.Axi4Pkg.all;

entity SpiMaster2Axis is
    Generic (
        SPI_CPOL_G      : SpiClockPolarity;
        SPI_CPHA_G      : SpiClockPhase;
        DATA_WIDTH_G    : natural := 16;
        N_CYCLES_IDLE_G : natural := 1
    );
    Port (
        clk_i : in STD_LOGIC;
        rst_i : in STD_LOGIC;

        -- SPI interface
        miso_i  : in  STD_LOGIC;
        mosi_o  : out STD_LOGIC;
        cs_o    : out STD_LOGIC;
        clk_o   : out STD_LOGIC;
        highz_o : out STD_LOGIC;

        -- Write interface
        axisWriteSrc_i : in  Axi4StreamSource;
        axisWriteDst_o : out Axi4StreamDestination;

        -- Read interface
        axisReadSrc_o : out Axi4StreamSource;
        axisReadDst_i : in  Axi4StreamDestination
    );
end SpiMaster2Axis;

architecture Behavioral of SpiMaster2Axis is

    constant CLOCK_IDLE_C   : STD_LOGIC := getIdleLevel(SPI_CPOL_G);
    constant CLOCK_ACTIVE_C : STD_LOGIC := getActiveLevel(SPI_CPOL_G);

    type StateType is (
            INIT_S,
            IDLE_S,
            WAIT_TO_ASSERT_CS_S,
            TRANSFER_S,
            DEASSERT_S
        );

    type AxiReadSrcStateType is (
            WAITING_S,
            HANDHAKE_S
        );

    type RegType is record
        state        : StateType;
        cs           : STD_LOGIC;
        highz        : STD_LOGIC;
        clock        : STD_LOGIC;
        tready       : STD_LOGIC;
        wrBuffer     : STD_LOGIC_VECTOR(DATA_WIDTH_G-1 downto 0);
        rdBuffer     : STD_LOGIC_VECTOR(DATA_WIDTH_G-1 downto 0);
        wrCounter    : integer range 0 to DATA_WIDTH_G-1;
        rdCounter    : integer range 0 to DATA_WIDTH_G-1;
        wrAllowed    : STD_LOGIC;
        csHold       : integer range 0 to N_CYCLES_IDLE_G-1;
        transferDone : STD_LOGIC;
        axiSrcState  : AxiReadSrcStateType;
        tvalid       : STD_LOGIC;
    end record RegType;

    constant REG_TYPE_INIT_C : RegType := (
            state        => INIT_S,
            cs           => '1',
            highz        => '1',
            clock        => '0',
            tready       => '0',
            wrBuffer     => (others => '0'),
            rdBuffer     => (others => '0'),
            wrCounter    => 0,
            rdCounter    => 0,
            wrAllowed    => '0',
            csHold       => 0,
            transferDone => '0',
            axiSrcState  => WAITING_S,
            tvalid       => '0'
        );

    signal r   : RegType;
    signal rin : RegType;

    constant AXI_FILL_ZEROS : STD_LOGIC_VECTOR(axisReadSrc_o.tdata'high - DATA_WIDTH_G downto 0) := (others => '0');

begin

    p_Comb     : process(all)
        variable v : RegType;
    begin
        v := r;

        v.clock := not r.clock;

        -- combinatorial logic
        case r.state is
            when INIT_S =>
                v.tready := '1';
                v.state  := IDLE_S;

                -- SPI_CPHA_0 requires to output the first bit on CS assert
                if (SPI_CPHA_G = SPI_CPHA_0) then
                    v.wrAllowed := '1';
                end if;

            when IDLE_S =>
                if (axisWriteSrc_i.tvalid = '1') then
                    -- sample data on axi
                    v.wrBuffer := axisWriteSrc_i.tdata(DATA_WIDTH_G-1 downto 0);
                    v.tready   := '0';

                    -- Assert CS on idle clock cycle
                    -- not is here because the idle clock cycle will happen next clock cycle
                    if (r.clock = not CLOCK_IDLE_C) then
                        v.cs    := '0';
                        v.highz := '0';
                        v.state := TRANSFER_S;
                    else
                        v.state := WAIT_TO_ASSERT_CS_S;
                    end if;
                end if;

            when WAIT_TO_ASSERT_CS_S =>
                v.cs    := '0';
                v.highz := '0';
                v.state := TRANSFER_S;

            when TRANSFER_S =>
                if ((r.clock = not CLOCK_IDLE_C and SPI_CPHA_G = SPI_CPHA_0) or
                        (r.clock = not CLOCK_ACTIVE_C and SPI_CPHA_G = SPI_CPHA_1)) then
                    if r.wrCounter < DATA_WIDTH_G - 1 then
                        if r.wrAllowed = '1' then
                            v.wrCounter := r.wrCounter + 1;
                        -- transition from High-Z state
                        else
                            v.wrAllowed := '1';
                        end if;
                    else
                        v.highz := '1';
                    end if;
                end if;

                if ((r.clock = not CLOCK_IDLE_C and SPI_CPHA_G = SPI_CPHA_1) or
                        (r.clock = not CLOCK_ACTIVE_C and SPI_CPHA_G = SPI_CPHA_0)) then
                    if r.rdCounter < DATA_WIDTH_G - 1 then
                        v.rdCounter := r.rdCounter + 1;
                    else
                        -- we read all bits
                        v.transferDone := '1';
                    end if;

                    v.rdBuffer(DATA_WIDTH_G-1 - r.rdCounter) := miso_i;
                end if;


                if r.transferDone = '1' and r.clock = not CLOCK_ACTIVE_C then
                    v.cs           := '1';
                    v.wrCounter    := 0;
                    v.rdCounter    := 0;
                    v.transferDone := '0';

                    -- need to reset the state for the next read
                    if (SPI_CPHA_G = SPI_CPHA_1) then
                        v.wrAllowed := '0';
                    end if;

                    -- wait aditional clock cycles if needed
                    if (N_CYCLES_IDLE_G > 0) then
                        v.state := DEASSERT_S;
                    else
                        v.state  := IDLE_S;
                        v.tready := '1';
                    end if;
                end if;

            when DEASSERT_S =>
                if (r.csHold = N_CYCLES_IDLE_G - 1) then
                    v.state  := IDLE_S;
                    v.tready := '1';
                else
                    v.csHold := r.csHold + 1;
                end if;

            when others =>
                v := REG_TYPE_INIT_C;
        end case;

        case r.axiSrcState is
            when WAITING_S =>
                if (r.transferDone = '1') then
                    v.tvalid      := '1';
                    v.axiSrcState := HANDHAKE_S;
                end if;

            when HANDHAKE_S =>
                if axisReadDst_i.tready = '1' then
                    v.tvalid      := '0';
                    v.axiSrcState := WAITING_S;
                end if;

            when others =>
                v := REG_TYPE_INIT_C;
        end case;

        if (rst_i = '1') then
            v := REG_TYPE_INIT_C;
        end if;

        rin <= v;
        -- Drive outputs
        mosi_o                <= r.wrBuffer(DATA_WIDTH_G-1 - r.wrCounter);
        clk_o                 <= r.clock;
        cs_o                  <= r.cs;
        highz_o               <= r.highz;
        axisWriteDst_o.tready <= r.tready;
        axisReadSrc_o.tvalid  <= r.tvalid;
        axisReadSrc_o.tdata   <= AXI_FILL_ZEROS & r.rdBuffer;
        axisReadSrc_o.tstrb   <= (others => '1');
        axisReadSrc_o.tkeep   <= (others => '1');
        axisReadSrc_o.tlast   <= '1';
        axisReadSrc_o.tid     <= (others => '0');
        axisReadSrc_o.tdest   <= (others => '0');
        axisReadSrc_o.twakeup <= '0';
    end process p_Comb;

    p_Seq : process(clk_i)
    begin
        if (rising_edge(clk_i)) then
            r <= rin;
        end if;
    end process p_Seq;
end Behavioral;
