
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
		
entity Master_SPI_MOSI is 
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
	i_SS		: in std_logic:='1'						-- tin hieu cho phep hoat dong
	
);
end Master_SPI_MOSI;

architecture main of Master_SPI_MOSI is	
	
	signal 	MOSI_rising		:std_logic:='0';
	signal	BUSY_rising		:std_logic:='0';
	signal	MOSI_falling	:std_logic:='0';
	signal	BUSY_falling	:std_logic:='0';
	signal	comple_rising	:std_logic:='0';
	signal	comple_falling	:std_logic:='0';
	
	signal	pre_SS	: std_logic := '1';
begin
	o_MOSI <= 	MOSI_rising 	when i_CPHA = '0'
			else 	MOSI_falling	when i_CPHA = '1';
	o_BUSY <=	BUSY_rising 	when i_CPHA = '0'
			else 	BUSY_falling	when i_CPHA = '1';
	o_comple <=	comple_rising 	when i_CPHA = '0'
			else 	comple_falling	when i_CPHA = '1';
				
MOSI_rising_edge: process(i_SCL,i_SS)

	variable frame_TX : std_logic_vector(7 downto 0);
	variable INDEX	: integer range 0 to 8 :=0;
	variable BUSY :std_logic := '0';
	variable count	:integer range 0 to 100 :=0;
	variable comple : std_logic :='0';
	
begin
	if(i_SS = '1'  or i_CPHA = '1' ) then
		comple := '0';
		BUSY 	:= '0';
		INDEX := 0;
		MOSI_rising <= '1';   
	elsif (i_SS = '0' and pre_SS = '1' and i_CPHA = '0' ) then		-- falling_edge cua SS
		frame_TX := i_Data_TX;
		MOSI_rising <= frame_TX(INDEX);
	elsif ( i_CPHA = '0' and i_SS = '0' and comple = '0'  )   then 		--rising_edge
		if(rising_edge(i_SCL)) then
			BUSY	:= '1';
			MOSI_rising <= frame_TX(INDEX);
			INDEX := INDEX +1;
			
			if(INDEX = 8) then
				comple	:= '1';
				BUSY 		:= '0';
			end if;
		end if;
		
	end if;
	BUSY_rising <= BUSY;
	comple_rising <= comple;
	pre_SS <= i_SS;
end process MOSI_rising_edge;

-----------------------CPHA=1  falling_edge---------------------------------
MOSI_falling_edge: process(i_SCL,i_SS)
	variable frame_TX : std_logic_vector(7 downto 0);
	variable INDEX	: integer range 0 to 8 :=0;
	variable BUSY :std_logic := '0';
	variable comple :std_logic := '0';
	
	
begin
	if(i_SS = '1'  or i_CPHA = '0' ) then
		comple := '0';
		BUSY 	:= '0';
		INDEX := 0;
		MOSI_falling <= '1';
		
		
	elsif (i_SS = '0' and pre_SS = '1' ) then		-- falling_edge cua SS
		frame_TX := i_Data_TX;
		MOSI_falling <= frame_TX(INDEX);
	elsif ( i_CPHA = '1' and i_SS = '0' and comple = '0' )   then 		--rising_edge		
		if(falling_edge(i_SCL)) then
				
			if( BUSY = '0' and i_CPOL = '0') then
				BUSY	:= '1';
				frame_TX := i_Data_TX;
				INDEX := INDEX +1;		-- index = 1
			end if;
			
			if( BUSY = '0' and i_CPOL = '1') then --- bo qua xung suon xuong dau
				BUSY	:= '1';
				frame_TX := i_Data_TX;
			end if;
			
			
			
			---------- truyen ----------------------------
			if( BUSY = '1') then
				MOSI_falling <= frame_TX(INDEX);
				INDEX := INDEX +1;
			
				if(INDEX = 8) then
					comple	:= '1';
					BUSY 		:= '0';
				end if;
			end if;
			---------------------------------
		end if;
	end if;
	BUSY_falling <= BUSY;
	comple_falling <= comple;
	pre_SS <= i_SS;
end process MOSI_falling_edge;
end main;
 