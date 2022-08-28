library ieee;
use ieee.std_logic_1164.all;

entity Main_UART is 
port(
	i_clk	: in std_logic;
	i_RX	: in std_logic;
	o_TX	: out std_logic
);
end Main_UART;
architecture main of Main_UART is
	signal enable_TX	: std_logic:='1';
	signal BUSY_TX		: std_logic:='0';
	signal Data_TX		: std_logic_vector (7 downto 0):="01010011";
	signal comple		: std_logic := '0';
	
	signal Data_RX		: std_logic_vector (7 downto 0);
	signal BUSY_RX		: std_logic:='0';
	signal RX_temp		:std_logic	:='1';
	signal TX_temp		:std_logic	:='1';
component TX is
port(
	i_clk			: in std_logic;
	i_enable_TX	: in std_logic;
	i_data		: in std_logic_vector (7 downto 0);
	o_BUSY		: out std_logic;
	o_comple		: out std_logic;							-- complement tran data
	o_TX_Line	: out std_logic
);
end component TX;

component RX is
port(
	i_clk			: in std_logic;
	i_RX_Line	: in std_logic;
	o_data		: out std_logic_vector (7 downto 0);
	o_BUSY		: out std_logic
);
end component RX;
begin
RX_temp <= TX_temp;
U1	: TX port map (i_clk,enable_TX,Data_TX,BUSY_TX,comple,TX_temp);
U2	: RX port map (i_clk,RX_temp,DaTa_RX,BUSY_RX);
--process(i_clk)
--begin
	--if(rising_edge(i_clk)) then
	--	RX_temp <= TX_temp;
	--end if;
--end process;
end main;