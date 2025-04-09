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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.SpiMaster2AxisPkg.all;
use work.SpiMasterPkg.all;
use work.Axi4Pkg.all;

entity SpiMaster is
    Generic (
        MARK_DEBUG_G    : string           := "false";
        SPI_CPOL_G      : SpiClockPolarity := SPI_CPOL_0;
        SPI_CPHA_G      : SpiClockPhase    := SPI_CPHA_0;
        DATA_WIDTH_G    : natural          := 16;
        N_CYCLES_IDLE_G : natural          := 1;
        UNUSED_READ_G   : boolean          := false;
        UNUSED_WRITE_G  : boolean          := false
    );
    Port (
        clk_i    : in STD_LOGIC;
        spiClk_i : in STD_LOGIC;
        rst_i    : in STD_LOGIC;

        -- SPI interface
        miso_i  : in  STD_LOGIC;
        mosi_o  : out STD_LOGIC;
        cs_o    : out STD_LOGIC;
        clk_o   : out STD_LOGIC;
        highz_o : out STD_LOGIC;

        -- Write interface
        axisWriteSrc_i : in  SpiMasterAxi4StreamSource;
        axisWriteDst_o : out Axi4StreamDestination;

        -- Read interface
        axisReadSrc_o : out SpiMasterAxi4StreamSource;
        axisReadDst_i : in  Axi4StreamDestination;
        run_i         : in  STD_LOGIC;
        overflow_o    : out STD_LOGIC
    );
end SpiMaster;

architecture Behavioral of SpiMaster is

    COMPONENT fifo_sync_data
        PORT (
            wr_rst_busy   : OUT STD_LOGIC;
            rd_rst_busy   : OUT STD_LOGIC;
            m_aclk        : IN  STD_LOGIC;
            s_aclk        : IN  STD_LOGIC;
            s_aresetn     : IN  STD_LOGIC;
            s_axis_tvalid : IN  STD_LOGIC;
            s_axis_tready : OUT STD_LOGIC;
            s_axis_tdata  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            m_axis_tvalid : OUT STD_LOGIC;
            m_axis_tready : IN  STD_LOGIC;
            m_axis_tdata  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT;

    signal syncRst : STD_LOGIC;

    signal axisWriteSrcSlow : axisWriteSrc_i'subtype;
    signal axisWriteDstSlow : Axi4StreamDestination;
    signal axisReadSrcSlow  : axisReadSrc_o'subtype;
    signal axisReadDstSlow  : Axi4StreamDestination;

    signal wr_rst_busyRead  : STD_LOGIC;
    signal rd_rst_busyRead  : STD_LOGIC;
    signal wr_rst_busyWrite : STD_LOGIC;
    signal rd_rst_busyWrite : STD_LOGIC;

    signal syncOverflow : STD_LOGIC;
    signal syncRun      : STD_LOGIC;

    ----------------------------------------------------------------------------
    attribute mark_debug                     : string;
    attribute mark_debug of syncRst          : signal is MARK_DEBUG_G;
    attribute mark_debug of axisWriteSrcSlow : signal is MARK_DEBUG_G;
    attribute mark_debug of axisWriteDstSlow : signal is MARK_DEBUG_G;
    attribute mark_debug of axisReadSrcSlow  : signal is MARK_DEBUG_G;
    attribute mark_debug of axisReadDstSlow  : signal is MARK_DEBUG_G;
    ----------------------------------------------------------------------------

begin

    u_SyncRst : entity work.SyncRst
        generic map (
            NUM_STAGES_G => 2
        )
        port map (
            clk_i      => spiClk_i,
            asyncRst_i => rst_i,
            syncRst_o  => syncRst
        );

    g_syncWrite : if (UNUSED_WRITE_G = false) generate
        u_syncWrite : fifo_sync_data
            PORT MAP (
                wr_rst_busy   => wr_rst_busyWrite,
                rd_rst_busy   => rd_rst_busyWrite,
                m_aclk        => spiClk_i,
                s_aclk        => clk_i,
                s_aresetn     => not rst_i,
                s_axis_tvalid => axisWriteSrc_i.tvalid,
                s_axis_tready => axisWriteDst_o.tready,
                s_axis_tdata  => axisWriteSrc_i.tdata,
                m_axis_tvalid => axisWriteSrcSlow.tvalid,
                m_axis_tready => axisWriteDstSlow.tready,
                m_axis_tdata  => axisWriteSrcSlow.tdata
            );
    end generate g_syncWrite;

    g_passWrite : if (UNUSED_WRITE_G = true) generate
        axisWriteDst_o   <= axisWriteDstSlow;
        axisWriteSrcSlow <= axisWriteSrc_i;
    end generate g_passWrite;

    g_syncRead : if (UNUSED_READ_G = false) generate
        u_syncRead : fifo_sync_data
            PORT MAP (
                wr_rst_busy   => wr_rst_busyRead,
                rd_rst_busy   => rd_rst_busyRead,
                m_aclk        => clk_i,
                s_aclk        => spiClk_i,
                s_aresetn     => not syncRst,
                s_axis_tvalid => axisReadSrcSlow.tvalid,
                s_axis_tready => axisReadDstSlow.tready,
                s_axis_tdata  => axisReadSrcSlow.tdata,
                m_axis_tvalid => axisReadSrc_o.tvalid,
                m_axis_tready => axisReadDst_i.tready,
                m_axis_tdata  => axisReadSrc_o.tdata
            );
    end generate g_syncRead;

    g_passRead : if (UNUSED_READ_G = true) generate
        axisReadSrc_o   <= axisReadSrcSlow;
        axisReadDstSlow <= axisReadDst_i;
    end generate g_passRead;

    u_SpiMaster2Axis : entity work.SpiMaster2Axis
        generic map (
            MARK_DEBUG_G    => "false",
            SPI_CPOL_G      => SPI_CPOL_G,
            SPI_CPHA_G      => SPI_CPHA_G,
            DATA_WIDTH_G    => DATA_WIDTH_G,
            N_CYCLES_IDLE_G => N_CYCLES_IDLE_G
        )
        port map (
            clk_i          => spiClk_i,
            rst_i          => syncRst,
            miso_i         => miso_i,
            mosi_o         => mosi_o,
            cs_o           => cs_o,
            clk_o          => clk_o,
            highz_o        => highz_o,
            axisWriteSrc_i => axisWriteSrcSlow,
            axisWriteDst_o => axisWriteDstSlow,
            axisReadSrc_o  => axisReadSrcSlow,
            axisReadDst_i  => axisReadDstSlow,
            run_i          => syncRun,
            overflow_o     => syncOverflow
        );

    u_SyncOverflow : entity work.Sync
        generic map (
            NUM_STAGES_G => 2
        )
        port map (
            clk_i => clk_i,
            rst_i => rst_i,
            sig_i => syncOverflow,
            sig_o => overflow_o
        );

    u_SyncRun : entity work.Sync
        generic map (
            NUM_STAGES_G => 2
        )
        port map (
            clk_i => spiClk_i,
            rst_i => syncRst,
            sig_i => run_i,
            sig_o => syncRun
        );
end Behavioral;
