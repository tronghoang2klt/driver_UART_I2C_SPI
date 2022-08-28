
-------------mode------------------------------------------
----mode 	| CPOL	| CPHA	| idle clock	| sample data and 
-----0			0			0			0					rising_edge
-----1			0			1			0					falling_edge
-----2			1			0			1					rising_edge
-----3			1			1			1					falling_edge	

-- in this example, we send or receive byte data
-- 1 master and slave
library ieee;
use	ieee.std_logic_1164.all;
library std;
use	std.standard.all;
library work;
use 	work.all;
		
entity Master_SPI is 
port(
	i_clk	:in std_logic;
	------------MOSI-------------
	
	o_MOSI	:out std_logic;
	i_Data_TX:in std_logic_vector (7 downto 0):="01101100";
	
	----------CPOL and CPHA, SS, clock----------
	i_CPOL	:in std_logic:='0';
	i_CPHA	:in std_logic:='0';
	i_SCL		:in std_logic;
	i_SS		:in std_logic:='1';
	
	-----------MISO------------------
	i_MISO	:in std_logic;
	o_Data_RX:out std_logic_vector (7 downto 0)
);
end Master_SPI;

architecture main of Master_SPI is


----------------- Master_SPI_SCL----------------
component Master_SPI_SCL is 
port(
	i_clk		:in std_logic;
	--i_enable_clk	:in std_logic;
	i_CPOL	: in std_logic;
	i_SS		:in std_logic :='1';
	o_SCL		: out std_logic
);
end component Master_SPI_SCL;
--------------------------------------------------


------------------Master_SPI_MOSI-----------------
component Master_SPI_MOSI is
port(
	o_comple	:out std_logic := '0';
	o_BUSY	:out std_logic :='0';
	
	------------MOSI-------------
	o_MOSI	:out std_logic:='0';
	i_Data_TX:in std_logic_vector (7 downto 0);
	
	----------CPOL and CPHA, SS, clock----------
	i_CPOL	:in std_logic;
	i_CPHA	:in std_logic;
	i_SCL		:in std_logic;
	i_SS		: in std_logic:='1'
	
);
end component Master_SPI_MOSI;
-----------------------------------------------


-----------Master_SPI_MISO---------------------
component Master_SPI_MISO is
port(
	o_comple	:out std_logic := '0';
	o_BUSY	: out std_logic:='0';
	-----------MISO------------------
	i_MISO	:in std_logic;
	o_Data_RX:out std_logic_vector (7 downto 0);
	----------CPOL and CPHA, SS, clock----------
	i_CPOL	:in std_logic;
	i_CPHA	:in std_logic;
	i_SCL		:in std_logic;
	i_SS		:in std_logic:='1'
);
end component Master_SPI_MISO;

----------------------------------------


signal	Busy_MOSI	:std_logic := '0';
signal	Busy_MISO	:std_logic :='0';
signal	pre_busy_mosi	:std_logic:=Busy_MOSI;
signal	SCL_temp		:std_logic;

signal   comple_MOSI	:std_logic := '0';
signal   comple_MISO	:std_logic := '0';

signal 	MOSI_temp	:std_logic:='0';
signal	MISO_temp	:std_logic;
--signal	i_enable_clk	:std_logic:='1';
signal	pre_SS		:std_logic:='1';
begin
MISO_temp <= MOSI_temp;
U1: Master_SPI_SCL port map (i_clk,i_CPOL,i_SS,SCL_temp);
U2: Master_SPI_MOSI port map (comple_MOSI,Busy_MOSI,MOSI_temp,i_Data_TX,i_CPOL,i_CPHA,SCL_temp,i_SS);
U3: Master_SPI_MISO port map (comple_MISO,Busy_MISO,MISO_temp,o_Data_RX,i_CPOL,i_CPHA,SCL_temp,i_SS);


end main;
 