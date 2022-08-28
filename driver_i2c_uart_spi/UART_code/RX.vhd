library ieee;
use ieee.std_logic_1164.all;
library std;
use std.standard.all;
library work;
use work.all;

entity RX is
port(
	i_clk			: in std_logic;								-- clock
	i_RX_Line	: in std_logic;								-- RX line
	o_data		: out std_logic_vector (7 downto 0);	-- data rev
	o_BUSY		: out std_logic								-- complement busY
);
end RX;

architecture main of RX is
	constant perscale	: integer range 0  to 5208:=5;		-- 50*10^6/5208=9600 bit/s
	type uart_state is (ready,start,data_rev,stop);
begin
process(i_clk)
	variable count	: integer range 0 to 5210:=0;
	variable state	: uart_state := ready;
	variable next_state	: uart_state := ready;
	variable BUSY	: std_logic:='0';
	variable frame	: std_logic_vector (9 downto 0);
	variable INDEX	: integer range 0 to 10 :=0;
	variable RX_rev: std_logic := '1';
	variable pre_RX_Line : std_logic := '1';
	
begin
	if (rising_edge(i_clk)) then
		case state is
		
			when ready =>
				BUSY := '0';
				INDEX	:=0;
				
			when start =>
				next_state := data_rev;
				frame(0) := '0';
			when data_rev =>
				if(count = perscale) then
					INDEX := INDEX +1;
					if(INDEX = 9) then
						next_state := stop;
					else
						frame(INDEX):= i_RX_Line;
						next_state :=data_rev;
					end if;
				count :=0;
				end if;
				
			when stop =>
				next_state	:= ready;
				o_data	<= frame (8 downto 1);
				frame(9) := '1';
		end case;
		
			
		if( BUSY = '1' ) then
			count := count +1;
		end if;
	
		if(i_RX_Line = '0' and pre_RX_Line ='1' and BUSY ='0') then		--falling_edge, start bit
			next_state	:= start;
			BUSY	:= '1';
		elsif BUSY = '0' then
			next_state	:= ready;
		end if;
		
	state	:= next_state;
	pre_RX_Line	:= i_RX_Line;
	o_BUSY	<= BUSY;
	
	end if;
end process;

end main;