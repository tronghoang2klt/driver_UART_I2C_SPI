library ieee;
use ieee.std_logic_1164.all;
library std;
use std.standard.all;
library work;
use work.all;

entity TX is 
port(
	i_clk			: in std_logic;							-- clock
	i_enable_TX	: in std_logic;							-- enable TX
	i_data		: in std_logic_vector (7 downto 0);	-- data tran
	o_BUSY		: out std_logic;							-- state uart
	o_comple		: out std_logic;							-- complement tran data
	o_TX_Line	: out std_logic							-- TX line
);
end TX;
architecture main of TX is
	constant perscale	: integer := 5;					--50*10^6/5208=9600 bit/s
	--signal 	BUSY		: std_logic:= '0';
	--signal	frame		: std_logic_vector (9 downto 0);	-- frame truyen
	type uart_state is (ready,start,data_transfer,stop); 
begin
process(i_clk,i_enable_TX)
	variable count	: integer range 0 to 5210 :=0;
	variable	frame		: std_logic_vector (9 downto 0);	-- frame truyen
	variable INDEX	: integer range 0 to 10		:=0;		
	variable	TX_Tran	: std_logic:='1';
	variable BUSY	: std_logic:='0';
	variable state	: uart_state := ready;
	variable next_state	: uart_state := ready;
	variable pre_enable	:std_logic:='0';
	variable o_comple_temp	: std_logic:='0';
begin
	if(i_enable_TX = '0') then
		state := ready;
		INDEX := 0;
		frame(9 downto 0 ) := "0000000000";
		BUSY	:= '0';
		o_comple_temp := '0';
		TX_Tran := '1';
	elsif(o_comple_temp = '0') then 
	if ( rising_edge(i_clk)) then
		case state is
		
		when ready	=>--trang thai duong truyen ko ban
			INDEX := 0;
			TX_Tran	:= '1';
			frame(0)		:= '0';				-- bit start
			frame(9)		:= '1';				-- bit stop
			frame(8 downto 1)	:=i_data;	-- data
			BUSY := '1';						-- duong truyen ban
			next_state	:= start;
			TX_Tran	:= '1';
			
			
		when start	=>-- truyen bit start
				TX_Tran	:= frame(INDEX);
				next_state :=data_transfer;
				
		when data_transfer	=>-- truyen cac bit data
			if(count = perscale) then
				INDEX := INDEX +1;
				if(INDEX = 9) then
					next_state := stop;
				else
					TX_Tran	:= frame(INDEX);
					next_state :=data_transfer;
				end if;
				count :=0;
			end if;
			
			
		when stop	=>-- truyen bit stop
			
				TX_Tran	:= frame(INDEX);
				next_state :=ready;
				o_comple_temp := '1';
				
			

		end case;
	
			if( BUSY = '1' ) then
			count := count +1;
			end if;
			
	end if;
	end if;
	
	state := next_state;
	o_BUSY <= BUSY;
	o_TX_Line <= TX_Tran;
	o_comple <= o_comple_temp;
end process;
end main;