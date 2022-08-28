library ieee;
use ieee.std_logic_1164.all;
library std;
use std.standard.all;
library work;
use work.all;
entity test1 is port(
	i_clk	: in std_logic;
	io_clk: inout std_logic;
	io_sda	: inout std_logic
	
);
end test1;
architecture main of test1 is
	
	type state_test	is (ready, start, stop);
	signal	state	: state_test:=ready;
	--signal count 	: integer range 0 to 6 :=0;
	signal	en_clk_inout	: std_logic	:=	'1';
	signal 	clk_out			: std_logic	:=	'0';
	signal	 clk_in			: std_logic	:= '1';
	
	signal	en_sda_inout	: std_logic	:=	'1';
	signal	 sda_out			: std_logic	:=	'0';
	signal	 sda_in			: std_logic	:=	'1';
	signal	x: std_logic:='0';
	signal	y: std_logic:='0';
begin
	io_clk <= clk_out when en_clk_inout = '1' else 'Z';
	io_sda <= sda_out when en_sda_inout = '1' else 'Z';
	
	process_1:process(x)
	begin
		if(rising_edge (x)) then
			y<= not y;
		end if;
	end process process_1;
	
	process_2:process(i_clk)
	begin
		if(rising_edge (i_clk)) then
			x<= not x;
		end if;
	
	end process process_2;
	process_3:process(i_clk,io_clk)
		variable perscale : integer := 6;
		variable count		: integer range 0 to 6:=0;
		variable time_1	: integer range 0 to 4:=0;
		
		variable	en_clk_inout_temp	: std_logic	:=	'1';
		variable clk_out_temp	: std_logic		:=	'0';
		variable clk_in_temp		: std_logic		:= '1';
		
		variable	en_sda_inout_temp	: std_logic	:=	'1';
		variable sda_out_temp	: std_logic		:=	'0';
		variable sda_in_temp		: std_logic		:= '1';
		variable a					:std_logic		:= '0';	
		variable b					:std_logic		:= '0';
	begin
			case a is 
			when '1' =>
				b:= '1';
			when '0' =>
				b:= '0';
				if(rising_edge (i_clk)) then
					b:='1';
				end if;
			end case;
			--- neu chay den 4 lan
			if(time_1 = 4 ) then
				-- slave kiem soat scl va sda
				en_clk_inout_temp := '0';
				en_sda_inout_temp	:= '0';
				time_1 := 0;
			end if;
			--- neu slave kiem soat scl
			if(en_clk_inout_temp = '0' ) then --- test1 doc en_clk_inout_temp vao
				en_clk_inout_temp	:= '0';
				clk_in_temp := io_clk;
				if(clk_in_temp = '1' ) then		-- neu co tin hieu suon len scl
					en_clk_inout_temp := '1';
					clk_out_temp		:= '1';
					--en_sda_inout_temp	:= '1';
					--sda_out_temp := '0';
					count:=perscale/2;
				end if;
				
			elsif(rising_edge(i_clk)) then
				count := count+1;
				if(count = perscale/2) then
					
					--en_sda_inout_temp := '1';
					--sda_out_temp 		:= '0';
					en_clk_inout_temp	:= '1';
					clk_out_temp		:= '1';
					--time_1 := time_1 +1;
				elsif(count=perscale) then
					en_sda_inout_temp := '1';
					sda_out_temp		:= '0';
					
					count := 0;
					
					en_clk_inout_temp	:= '1';
					clk_out_temp	:= '0';
					time_1 := time_1 +1;
				end if;
			end if;
		en_clk_inout <= en_clk_inout_temp;
		en_sda_inout <= en_sda_inout_temp;
		clk_in	<= clk_in_temp;
		clk_out	<= clk_out_temp;
		sda_in	<= sda_in_temp;
		sda_out	<= sda_out_temp;
	end process process_3;
end main;