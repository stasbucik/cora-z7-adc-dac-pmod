library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.Axi4Pkg.all;

entity ControlRegister is
    Generic (
        MARK_DEBUG_G  : string                := "false";
        AXI_ADDRESS_G : unsigned(31 downto 0) := x"8000_0000";
        WIDTH_G       : positive              := 32
    );
    Port (
        clk_i : in STD_LOGIC;
        rst_i : in STD_LOGIC;

        axiSrc_i : in  Axi4Source;
        axiDst_o : out Axi4Destination;

        reg_o : out STD_LOGIC_VECTOR(WIDTH_G-1 downto 0)
    );
end ControlRegister;

architecture Behavioral of ControlRegister is

    signal writeCtrl : STD_LOGIC;
    signal dataWrite : STD_LOGIC_VECTOR(WIDTH_G-1 downto 0);
    signal dataRead  : STD_LOGIC_VECTOR(WIDTH_G-1 downto 0);

    -----------------------------------------------------------------------------
    attribute mark_debug              : string;
    attribute mark_debug of writeCtrl : signal is MARK_DEBUG_G;
    attribute mark_debug of dataWrite : signal is MARK_DEBUG_G;
    attribute mark_debug of dataRead  : signal is MARK_DEBUG_G;
    -----------------------------------------------------------------------------

begin

    u_CtrlRegAxi4Iface : entity work.CtrlRegAxi4Iface
        generic map (
            MARK_DEBUG_G  => "true",
            WIDTH_G       => WIDTH_G,
            AXI_ADDRESS_G => AXI_ADDRESS_G
        )
        port map (
            clk_i         => clk_i,
            rst_i         => rst_i,
            axiReadSrc_i  => axiSrc_i.rd,
            axiReadDst_o  => axiDst_o.rd,
            axiWriteSrc_i => axiSrc_i.wr,
            axiWriteDst_o => axiDst_o.wr,
            writeEnable_o => writeCtrl,
            data_o        => dataWrite,
            data_i        => dataRead
        );

    u_SimpleRegister : entity work.SimpleRegister
        generic map (
            WIDTH_G => WIDTH_G
        )
        port map (
            clk_i       => clk_i,
            rst_i       => rst_i,
            din_i       => dataWrite,
            dout_o      => dataRead,
            writeCtrl_i => writeCtrl
        );

end Behavioral;