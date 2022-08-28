
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
		
entity Master_SPI_MISO is 
port(
	o_comple	:out std_logic := '0';
	o_BUSY	:out std_logic :='0';
		-----------MISO------------------
	i_MISO	:in std_logic;
	o_Data_RX:out std_logic_vector (7 downto 0);
	----------CPOL and CPHA, SS, clock----------
	i_CPOL	:in std_logic;
	i_CPHA	:in std_logic;
	i_SCL		:in std_logic;
	i_SS		:in std_logic:='1'

);
end Master_SPI_MISO;

architecture main of Master_SPI_MISO is
	
	signal 	data_rising		:std_logic_vector(7 downto 0);
	signal	BUSY_rising		:std_logic;
	signal	data_falling	:std_logic_vector(7 downto 0);
	signal	BUSY_falling	:std_logic;
	signal	comple_rising	:std_logic:='0';
	signal	comple_falling	:std_logic:='0';
begin
	o_Data_RX 	<= 	data_rising 	when i_CPHA = '1'
					else 	data_falling	when i_CPHA = '0';
	o_BUSY 		<=		BUSY_rising 	when i_CPHA = '1'
					else 	BUSY_falling	when i_CPHA = '0';
	o_comple 	<=	comple_rising 		when i_CPHA = '1'
					else 	comple_falling	when i_CPHA = '0';

--------------------CPHA = 1, rising_edge-------------------	
MISO_rising_edge: process(i_SCL,i_SS)

	variable frame_RX : std_logic_vector(7 downto 0);
	variable INDEX	: integer range 0 to 8 :=0;
	variable	BUSY	:std_logic:='0';
	
	variable comple : std_logic := '0';
begin
	if ( i_SS = '1' or i_CPHA = '0') then
		
		BUSY := '0';
		comple := '0';
	elsif ( i_CPHA = '1' and i_SS = '0'  and comple = '0' ) then 		--rising_edge sample
		if(rising_edge(i_SCL)) then
			BUSY := '1';
			frame_RX(INDEX):=i_MISO;
			INDEX := INDEX +1;
			if(INDEX = 8) then
				data_rising <= frame_RX;
				comple := '1';
				BUSY := '0';
				INDEX := 0;
			end if;
		end if;
		
	end if;
	BUSY_rising <= BUSY;
	comple_rising <= comple;
end process MISO_rising_edge;
-----------------------------------------------------------------


-----------CPHA =0, falling_edge-------------------------------
MISO_falling_edge: process(i_SCL,i_SS)

	variable frame_RX : std_logic_vector(7 downto 0);
	variable INDEX	: integer range 0 to 8 :=0;
	variable pre_SS	:std_logic:='1';
	variable	BUSY	:std_logic:='0';
	variable count : integer range 0 to 10:=0;
	
	variable comple  :std_logic := '0';
begin
	if( i_SS = '1'  or i_CPHA = '1') then
		BUSY := '0';
		count:=0;
	
		INDEX :=0;
		comple := '0';
	elsif ( i_CPHA = '0' and i_SS = '0'  and comple = '0') then 			---- falling_edge sample time
		if(falling_edge(i_SCL)) then
		
			
		if(count = 0 and BUSY = '0' and i_CPOL = '0') then--- suon xuong dau tien
			BUSY	:= '1';
		end if;
		
		if(count = 1 and BUSY = '0' and i_CPOL = '1') then---mat 1 suon xuong dau
			BUSY	:= '1';
		end if;
		
		count:=count+1;
		
		if(BUSY = '1') then
		
			frame_RX(INDEX):=i_MISO;
			INDEX := INDEX +1;
			if( INDEX = 8) then
				comple := '1';
				count:= 0;
				BUSY := '0';
				INDEX := 0;
				data_falling <= frame_RX;
			end if;
			
		end if;
				
		end if;
		
	end if;
	BUSY_falling <= BUSY;
	comple_falling<=comple;
end process MISO_falling_edge;

end main;
 