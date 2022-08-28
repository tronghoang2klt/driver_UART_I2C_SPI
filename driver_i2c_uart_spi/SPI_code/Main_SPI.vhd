library ieee;
use	ieee.std_logic_1164.all;
library std;
use	std.standard.all;
library work;
use work.all;

entity Main_SPI is
port(
	i_clk	: in std_logic;
	i_SS	: in std_logic;
	i_CPOL	:in std_logic;
	i_CPHA	:in std_logic
);
end Main_SPI;

architecture main of Main_SPI is
signal MOSI_temp	:std_logic;
signal Busy		:std_logic:='0';
signal data_tx	:std_logic_vector(7 downto 0):="10110010";
signal SCL_temp	:std_logic;
component Master_SPI_MOSI is
port(
	o_BUSY	:out std_logic :='0';
	------------MOSI-------------
	o_MOSI	:out std_logic;
	i_Data_TX:in std_logic_vector (7 downto 0);
	
	----------CPOL and CPHA, SS, clock----------
	i_CPHA	:in std_logic;
	i_SCL		:in std_logic;
	i_SS		: in std_logic:='1'
	
);
end component Master_SPI_MOSI;

component Master_SPI_SCL is
port(
	i_clk		:in std_logic;
	i_CPOL	: in std_logic;
	i_SS		:in std_logic :='1';
	o_SCL		: out std_logic
);
end component Master_SPI_SCL;
begin
U1: Master_SPI_MOSI port map (Busy,MOSI_temp,data_tx,i_CPHA,SCL_temp,i_SS);
U2: Master_SPI_SCL port map (i_clk,i_CPOL,i_SS,SCL_temp);
end main;