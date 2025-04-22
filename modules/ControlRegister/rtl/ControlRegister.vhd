library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.Axi4Pkg.all;

entity ControlRegister is
    Generic (
        MARK_DEBUG_G  : string                := "false";
        AXI_ADDRESS_G : unsigned(31 downto 0) := x"8000_0000"
    );
    Port (
        clk_i : in STD_LOGIC;
        rst_i : in STD_LOGIC;

        axiSrc_i : in  Axi4Source;
        axiDst_o : out Axi4Destination
    );
end ControlRegister;

architecture Behavioral of ControlRegister is

    constant WIDTH_C : natural := 32;

    signal writeCtrl : STD_LOGIC;
    signal dataWrite : STD_LOGIC_VECTOR(WIDTH_C-1 downto 0);
    signal dataRead  : STD_LOGIC_VECTOR(WIDTH_C-1 downto 0);

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
            WIDTH_G       => WIDTH_C,
            AXI_ADDRESS_G => AXI_ADDRESS_G
        )
        port map (
            clk_i         => clk_i,
            rst_i         => rst_i,
            axiSrc_i      => axiSrc_i,
            axiDst_o      => axiDst_o,
            writeEnable_o => writeCtrl,
            data_o        => dataWrite,
            data_i        => dataRead
        );

    u_SimpleRegister : entity work.SimpleRegister
        generic map (
            WIDTH_G => WIDTH_C
        )
        port map (
            clk_i       => clk_i,
            rst_i       => rst_i,
            din_i       => dataWrite,
            dout_o      => dataRead,
            writeCtrl_i => writeCtrl
        );

end Behavioral;