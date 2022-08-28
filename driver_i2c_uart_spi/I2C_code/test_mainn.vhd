library ieee;
use ieee.std_logic_1164.all;
library std;
use std.standard.all;
library work;
use work.all;
entity test_mainn is port(
	i_clk	: in std_logic;
	io_clk	: inout std_logic;
	io_sda	: inout std_logic
	
);
end test_mainn;
architecture main of test_mainn is
signal y_q :std_logic:='0';
signal clk	: std_logic:='1';
signal	perscale	: integer:=6;
component test1 is port( 
	i_clk	: in std_logic;
	io_clk: inout std_logic;
	io_sda	: inout std_logic
);
end component test1;


component test2 is port( 
	i_clk	: in std_logic;
	io_clk: inout std_logic;
	io_sda	: inout std_logic
);
end component test2;

begin
U1: test1 port map (i_clk,io_clk,io_sda);
U2: test2 port map (i_clk,io_clk,io_sda);
tao_xung:process(i_clk)
	variable count 	: integer range 0 to 6:=0;
begin
	if(rising_edge(i_clk)) then
		if(count = perscale/2) then
			clk <= not clk;
		end if;
	end if;
end process tao_xung;
test:process(i_clk,clk)
begin
	if(rising_edge(i_clk)) then
		if(rising_edge(clk)) then
			y_q <= not y_q;
		end if;
	end if;
end process test;
end main;