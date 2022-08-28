library ieee;
use ieee.std_logic_1164.all;
library std;
use std.standard.all;
library work;
use work.all;
entity test2 is port(
	i_clk	: in std_logic;
	io_clk: inout std_logic;
	io_sda	: inout std_logic
);
end test2;
architecture main of test2 is
	signal	en_clk_inout	: std_logic	:=	'0';
	signal 	clk_out			: std_logic	:=	'1';
	signal	clk_in			: std_logic	:= '0';
	
	signal	en_sda_inout	: std_logic	:=	'0';
	signal	 sda_out			: std_logic	:=	'1';
	signal	 sda_in			: std_logic	:=	'0';
	signal 	pre_clk			: std_logic := '0';
	signal  pre_i_clk			: std_logic	:= '0';
	signal   pre_sda			: std_logic	:= '0';
	--signal count	: integer range 0 to 7 :=0;
begin
	io_clk <= clk_out when en_clk_inout = '1' else 'Z';
	io_sda <= sda_out when en_sda_inout = '1' else 'Z';
	
	process(io_clk,i_clk)
		variable perscale : integer := 6;
		variable count		: integer range 0 to 20:=0;
		variable time_1	: integer range 0 to 4:=0;
		variable	en_clk_inout_temp	: std_logic	:=	'0';
		variable clk_out_temp	: std_logic		:=	'1';
		variable clk_in_temp		: std_logic		:= '0';
		
		variable	en_sda_inout_temp	: std_logic	:=	'0';
		variable sda_out_temp	: std_logic		:=	'1';
		variable sda_in_temp		: std_logic		:= '0';
		
		variable temp : integer range 0 to 10:=0;
	begin
		if(time_1 = 4 ) then
			en_clk_inout_temp := '1';
			clk_out_temp		:= '0';
			
			en_sda_inout_temp	:= '1';
			sda_out_temp		:= '1';
			time_1 := 0;
			temp:=3;
		end if;
		if(en_clk_inout_temp = '1') then -- danh quyen kiemr soat scl
			
			if(rising_edge (i_clk) ) then
				count := count +1;
			if(count <  perscale ) then
				en_clk_inout_temp	:= '1';
				clk_out_temp		:= '0';
			
				en_sda_inout_temp	:= '1';
				sda_out_temp		:= '1';
				temp:=4;
			elsif(count =  perscale) then
				en_clk_inout_temp	:= '1';
				clk_out_temp		:= '1';
				--en_clk_inout_temp	:= '0';
				temp := 6;
			elsif(count >  perscale) then
				en_clk_inout_temp	:= '0';
				clk_in_temp			:=io_clk;
				en_sda_inout_temp	:= '0';
				temp:=9;
			end if;
			end if;
		elsif(en_clk_inout_temp = '0' and rising_edge(io_clk)) then	-- nhan xung 
			
			en_sda_inout_temp	:= '0';
			sda_out_temp		:= '0';
			--end if;
		elsif (en_clk_inout_temp = '0' and falling_edge (io_clk)) then
			time_1	:= time_1 + 1;
		end if;
		en_clk_inout <= en_clk_inout_temp;
		en_sda_inout <= en_sda_inout_temp;
		clk_in	<= clk_in_temp;
		clk_out	<= clk_out_temp;
		sda_in	<= sda_in_temp;
		sda_out	<= sda_out_temp;
		pre_clk	<= clk_in;
		pre_i_clk	<= i_clk;
		pre_sda	<= sda_in;
	end process;
end main;