----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/31/2025 01:28:32 PM
-- Design Name: 
-- Module Name: Axi4Pkg - 
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

package Axi4Pkg is

	----------------------------------------------------------------------------
	type Axi4StreamSource is record
		TVALID  : STD_LOGIC;
		TDATA   : STD_LOGIC_VECTOR;
		TSTRB   : STD_LOGIC_VECTOR;
		TKEEP   : STD_LOGIC_VECTOR;
		TLAST   : STD_LOGIC;
		TID     : STD_LOGIC_VECTOR;
		TDEST   : STD_LOGIC_VECTOR;
		TUSER   : STD_LOGIC_VECTOR;
		TWAKEUP : STD_LOGIC;
	end record Axi4StreamSource;

	type Axi4StreamDestination is record
		TREADY : STD_LOGIC;
	end record Axi4StreamDestination;

	----------------------------------------------------------------------------


	constant AXI_DATA_WIDTH_C : natural := 32;
	constant AXI_ADDR_WIDTH_C : natural := 32;

	type Axi4ReadSource is record
		-- Address
		ARID     : STD_LOGIC_VECTOR(0 downto 0);
		ARADDR   : STD_LOGIC_VECTOR(AXI_ADDR_WIDTH_C-1 downto 0);
		ARLEN    : STD_LOGIC_VECTOR(7 downto 0);
		ARSIZE   : STD_LOGIC_VECTOR(2 downto 0);
		ARBURST  : STD_LOGIC_VECTOR(1 downto 0);
		ARLOCK   : STD_LOGIC_VECTOR(0 downto 0);
		ARCACHE  : STD_LOGIC_VECTOR(3 downto 0);
		ARPROT   : STD_LOGIC_VECTOR(2 downto 0);
		ARQOS    : STD_LOGIC_VECTOR(3 downto 0);
		ARREGION : STD_LOGIC_VECTOR(3 downto 0);
		ARUSER   : STD_LOGIC_VECTOR(0 downto 0);
		ARVALID  : STD_LOGIC;
		-- Data
		RREADY : STD_LOGIC;
	end record Axi4ReadSource;

	type Axi4ReadDestination is record
		-- Address
		ARREADY : STD_LOGIC;
		-- Data
		RID    : STD_LOGIC_VECTOR(0 downto 0);
		RDATA  : STD_LOGIC_VECTOR(AXI_DATA_WIDTH_C-1 downto 0);
		RRESP  : STD_LOGIC_VECTOR(1 downto 0);
		RLAST  : STD_LOGIC;
		RUSER  : STD_LOGIC_VECTOR(0 downto 0);
		RVALID : STD_LOGIC;
	end record Axi4ReadDestination;

	type Axi4WriteSource is record
		-- Address
		AWID     : STD_LOGIC_VECTOR(0 downto 0);
		AWADDR   : STD_LOGIC_VECTOR(AXI_ADDR_WIDTH_C-1 downto 0);
		AWLEN    : STD_LOGIC_VECTOR(7 downto 0);
		AWSIZE   : STD_LOGIC_VECTOR(2 downto 0);
		AWBURST  : STD_LOGIC_VECTOR(1 downto 0);
		AWLOCK   : STD_LOGIC_VECTOR(0 downto 0);
		AWCACHE  : STD_LOGIC_VECTOR(3 downto 0);
		AWPROT   : STD_LOGIC_VECTOR(2 downto 0);
		AWQOS    : STD_LOGIC_VECTOR(3 downto 0);
		AWREGION : STD_LOGIC_VECTOR(3 downto 0);
		AWUSER   : STD_LOGIC_VECTOR(0 downto 0);
		AWVALID  : STD_LOGIC;
		-- Data
		WID    : STD_LOGIC_VECTOR(0 downto 0);
		WDATA  : STD_LOGIC_VECTOR(AXI_DATA_WIDTH_C-1 downto 0);
		WSTRB  : STD_LOGIC_VECTOR(AXI_DATA_WIDTH_C/8-1 downto 0);
		WLAST  : STD_LOGIC;
		WUSER  : STD_LOGIC_VECTOR(0 downto 0);
		WVALID : STD_LOGIC;
		-- Response
		BREADY : STD_LOGIC;
	end record Axi4WriteSource;

	type Axi4WriteDestination is record
		-- Address
		AWREADY : STD_LOGIC;
		-- Data
		WREADY : STD_LOGIC;
		-- Response
		BID    : STD_LOGIC_VECTOR(0 downto 0);
		BRESP  : STD_LOGIC_VECTOR(1 downto 0);
		BUSER  : STD_LOGIC_VECTOR(0 downto 0);
		BVALID : STD_LOGIC;
	end record Axi4WriteDestination;

	type Axi4Source is record
		rd : Axi4ReadSource;
		wr : Axi4WriteSource;
	end record Axi4Source;

	type Axi4Destination is record
		rd : Axi4ReadDestination;
		wr : Axi4WriteDestination;
	end record Axi4Destination;

end package Axi4Pkg;

package body Axi4Pkg is
end package body Axi4Pkg;