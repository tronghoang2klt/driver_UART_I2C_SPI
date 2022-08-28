library ieee;
use	ieee.std_logic_1164.all;
library std;
use	std.standard.all;
library work;
use 	work.all;

entity Master_SPI_SCL is
port(
	i_clk		:in std_logic;
	--i_enable_clk	:in std_logic;
	i_CPOL	: in std_logic;
	i_SS		:in std_logic :='1';
	o_SCL		: out std_logic
);
end Master_SPI_SCL;

architecture main of Master_SPI_SCL is
	constant perscale	: integer := 5;
	signal count_clk	: integer range 0 to 10 ; -- tao  clock
	
	signal	scl_idle	:std_logic:='0';
	signal 	first		:std_logic:='0';
	signal   o_SCL_temp	: std_logic:='0';
	
begin
	scl_idle <= '0' when i_CPOL = '0' else
					'1' when i_CPOL = '1';
	o_SCL<= scl_idle when first = '0' else
				o_SCL_temp when first = '1';
	count_clk <= 8 when i_CPOL = '0' else
					 9 when i_CPOL = '1';
process(i_clk)
	variable count	:integer range 0 to 5210 := 1;
	variable	SCL_temp	:std_logic:=scl_idle;
	variable 	index			:integer range 0  to 10 :=0;
	variable   comple		:std_logic := '0';
begin
	if(i_SS = '1' ) then
		count:=1;
		SCL_temp:=scl_idle;
		index := 0;
		comple := '0';
	elsif(rising_edge(i_clk)) then
		first <= '1';
		
		if( comple = '0' ) then
			
				if(count = 0) then
					SCL_temp := not SCL_temp;
					count := count +1;
					
					--------------- xen da tao duoc bao nhiu xung
					if(i_CPOL = '0') then
						if (SCL_temp = '0') then
							index := index +1;
						end if;
					else --- i_cpol = 1
						if (SCL_temp = '1') then
							index := index +1;
						end if;
					end if;
					if(index = count_clk) then
						comple := '1';
					end if;
					--------------------------------------------------
					
				elsif (count=perscale) then
					count:= 0;
				else
					count := count +1;
				end if;
		else
			SCL_temp := SCL_idle;
		end if;
	end if;
	o_SCL_temp <= SCL_temp;
end process;
end main;