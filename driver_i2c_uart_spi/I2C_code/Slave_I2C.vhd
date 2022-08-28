library ieee;
use 	ieee.std_logic_1164.all;
library std;
use std.standard.all;
library work;
use work.all;

entity Slave_I2C is port (
	i_en		: in std_logic;								-- cho phep slave truyen nhan
	i_clk		: in std_logic;
	i_addr	: in std_logic_vector ( 6 downto 0);
	i_data_tran	: in std_logic_vector(7 downto 0);
	o_data_recv	: out std_logic_vector(7 downto 0);
	io_SDA	: inout std_logic;
	io_SCL	: inout std_logic
	
);
end Slave_I2C;

architecture main of Slave_I2C is
	signal sda_out	: std_logic:='1';
	signal sda_in	: std_logic:='1';
	
	signal en_sda_inout	: std_logic:='0';-- 1 out, 0 in
	signal scl_out	: std_logic:='1';
	signal scl_in	: std_logic:='1';
	--signal pre_scl	: std_logic:='1';
	signal en_scl_inout	: std_logic:='0';-- 1 out, 0 in
	signal perscale	: integer range 0 to 5210:=12;

	type 	 state_I2C	is (ready,start,addr,wr,ack1,data_tran,data_recv,ack2_master,ack2_slave,stop);
	signal thoidoi : integer range 0 to 10:=0;
	signal state	: state_I2C:=ready;
	--signal en_temp_2	: std_logic :='0';
	--signal en_state_tran : std_logic:='0';
begin
	io_SDA <= sda_out when en_sda_inout = '1' else 'Z';
	io_SCL <= scl_out when en_scl_inout = '1' else 'Z';


-------------------------------------------------------------------------------------
main_process:process(i_en,io_SCL,io_SDA,i_clk)
	variable frame_i2c	: std_logic_vector (19 downto 0);
	variable index_i2c	: integer range 0 to 19:=0; 
	variable count 		: integer range 0 to 5220 :=0;
	
	variable en_state_tran : std_logic:='0';
	variable en_temp		: std_logic	:='0';
	variable en_temp_2		: std_logic	:='0';
	variable time_repeat	: integer range 0 to 2:=0;
	
	variable sda_out_temp			: std_logic:='1';
	variable sda_in_temp			: std_logic:='1';
	variable en_sda_inout_temp	: std_logic:='1';-- 1 out, 0 in
	variable pre_sda	: std_logic:='1';
	
	variable scl_out_temp			: std_logic:='1';
	variable scl_in_temp			: std_logic:='1';
	variable en_scl_inout_temp	: std_logic:='1';-- 1 out, 0 in
	variable pre_scl	: std_logic:='1';
	
begin
	if(i_en = '0' ) then
		en_sda_inout_temp := '1';
		sda_out_temp 		:= '1';
		en_scl_inout_temp := '1';
		scl_out_temp 		:= '1';
		state 				<= ready;
		
		----- state =  data_tran --------
		----- slave giu scl xuong low-----
		----- slave giu SDA, SDA-out --------------
	elsif(en_state_tran = '1') then
		if(rising_edge(i_clk)) then
			count:=count +1;
			--thoidoi	<= 5;
			en_scl_inout 	<= '1';
			scl_out			<= '0';
			
			if(count = perscale) then
				en_scl_inout 	<= '1';
				scl_out			<= '1';
				
				-- 11
			end if;
			if(count = perscale +1) then
				count:=0;
				en_temp_2			:= '1';
				en_state_tran	 	:= '0';
				thoidoi	<= 5;
				en_sda_inout 	<= '1';
				sda_out		 	<= i_data_tran(0);--truyen frame_i2c(10)
				--index_i2c 		:= index_i2c+1;				-- 11
			end if;
		end if;
	
	
		else 
			
			case state is
			
				when ready 	=>
					index_i2c := 0;
					--frame_i2c(7 downto 1 ) := i_addr;	--address
					-- frame_i2c(9) is ack1
					state <= start;
					en_sda_inout_temp := '0';--high z
					sda_out_temp		:= '1';
					sda_in_temp 		:= '1';
					en_scl_inout_temp := '0';--high z
					scl_out_temp 		:= '1';
					scl_in_temp 		:= '1';
					
				when start 	=>
					en_sda_inout_temp := '0';
					pre_sda				:= sda_in_temp;
					sda_in_temp			:= io_SDA;
					en_scl_inout_temp := '0';
					pre_scl				:= scl_in_temp;
					scl_in_temp := io_SCL;
					if( pre_sda = '1' and sda_in_temp = '0') then				-- sda xuong low
						frame_i2c(index_i2c):= sda_in_temp;
						en_temp		:= '1';
					end if;
					if(pre_scl = '1' and scl_in_temp = '0' and en_temp = '1') then			-- scl xuong low
						state <= addr;
						en_temp := '0';
						index_i2c := index_i2c+1;	-- index_i2c =1
					end if;
					
					
				when addr	=>
					en_scl_inout_temp := '0';
					pre_scl				:= scl_in_temp;
					scl_in_temp 		:= io_SCL;
					
					en_sda_inout_temp := '0';
					--sda_in_temp			:= io_SDA;
					if(pre_scl = '0' and scl_in_temp = '1') then			-- suon len cua scl
						en_sda_inout_temp := '0';
						sda_in_temp			:= io_SDA;
						frame_i2c(index_i2c) := sda_in_temp;--frame_i2c)
						index_i2c := index_i2c+1;	
						if(index_i2c = 8) then
							state <= wr;
						end if;
					end if;
					
					
				when wr		=>
					en_scl_inout_temp := '0';
					pre_scl				:= scl_in_temp;
					scl_in_temp 		:= io_SCL;
					en_sda_inout_temp := '0';
					--sda_in_temp			:= io_SDA;
					if(pre_scl = '0' and scl_in_temp = '1') then			-- suon len cua scl
						en_sda_inout_temp := '0';
						sda_in_temp			:= io_SDA;
						frame_i2c(index_i2c) := sda_in_temp;
						index_i2c := index_i2c+1;		-- index_i2c =9
						if(index_i2c = 9) then
							state <= ack1;
						end if;
					end if;
					
				when ack1	=>---- doc du lieu phan hoi o suon xuong cua SCL
					en_scl_inout_temp := '0';
					pre_scl				:= scl_in_temp;
					scl_in_temp 		:= io_SCL;
					--en_sda_inout_temp := '1';				-- sda out enable
					if(pre_scl = '0' and scl_in_temp = '1') then			-- suon len cua scl
						
						en_sda_inout_temp := '1';
						--- neu dia chi dung
						if( frame_i2c(7 downto 1) = i_addr) then		
							-- ghi sda out la 0
							en_sda_inout_temp := '1';	
							sda_out_temp 		:= '0';
							
							frame_i2c(index_i2c) := '0';	-- frame_i2c(9)
							index_i2c := index_i2c+1;		-- index_i2c =10
							
							if( frame_i2c(8) = '0' ) then	-- master write, slave recv
								state <= data_recv;
							else
								state <= data_tran;
								frame_i2c(17 downto 10) := i_data_tran;
								
							end if;
						--- neu dia chi khong dung
						else	
							en_sda_inout_temp := '1';
							sda_out_temp := '1';
							state <= stop;
						end if;
					end if;
					
				when data_tran	=>
					if(en_temp_2 = '0' and en_state_tran = '0') then
						en_scl_inout_temp := '0';
						pre_scl				:= scl_in_temp;
						scl_in_temp 		:= io_SCL;
						if( pre_scl = '1' and scl_in_temp = '0') then	--khi SCL xuong low
							-- keo SCL xuong 0
							en_scl_inout	<= '1';
							scl_out 			<= '0';
							
							--en_temp_2			:= '1';
							--index_i2c := index_i2c+1;
							en_state_tran		:= '1';
							count :=0;
							thoidoi <= 3;
						end if;
					elsif (en_temp_2 = '1') then
						en_scl_inout_temp := '0';
						pre_scl	:=scl_in_temp;
						scl_in_temp			:= io_SCL;
						thoidoi <= 7;
						if(pre_scl = '0' and scl_in_temp = '1') then			-- suon len scl
							en_sda_inout_temp := '1';
							sda_out_temp := frame_i2c(index_i2c);
							index_i2c := index_i2c+1;
								thoidoi <= 9;
							if(index_i2c = 18) then
								state <= ack2_master;
								
								en_temp_2	:= '0';
							end if;
						end if;
					end if;
					
					
				when data_recv	=>
					en_scl_inout_temp := '0';
					pre_scl				:= scl_in_temp;
					scl_in_temp 		:= io_SCL;
					--en_sda_inout_temp := '0';
					--sda_in_temp			:= io_SDA;
					if(en_temp = '0' and pre_scl = '0' and scl_in_temp = '1') then			--
						en_sda_inout_temp := '0';
						sda_in_temp			:= io_SDA;
						en_temp				:= '1';
					end if;
					if(en_temp = '1' and pre_scl = '1' and scl_in_temp = '0') then			-- suon len cua scl
						en_sda_inout_temp := '0';
						sda_in_temp			:= io_SDA;
						frame_i2c(index_i2c) := sda_in_temp;
						index_i2c := index_i2c+1;		
						if(index_i2c = 18) then
							state <= ack2_slave;
							en_temp	:='0';
					end if;
					end if;
					
				when ack2_master =>
					en_scl_inout_temp := '0';
					pre_scl				:= scl_in_temp;
					scl_in_temp 		:= io_SCL;
					
					if(en_temp = '0' and pre_scl = '0' and scl_in_temp = '1') then			-- suon xuong cua scl
						en_sda_inout_temp := '0';
						sda_in_temp			:= io_SDA;
						en_temp			:= '1';
					end if;
					
					if( en_temp = '1' and pre_scl = '1' and scl_in_temp = '0') then			-- suon len cua scl
						en_sda_inout_temp := '0';
						sda_in_temp			:= io_SDA;
						frame_i2c(index_i2c) := sda_in_temp;
						if( frame_i2c(index_i2c) = '0') then -- master send  nack bit
							state <= stop;
							index_i2c := index_i2c+1;		-- index_i2c =19
							en_temp	:= '0';
						else											-- master send ack bit
							----- reapeat data tran 3 time
							
							if(time_repeat = 2) then
								state <= stop;
								time_repeat := 0;
							else
								time_repeat := time_repeat +1;
								state <= data_tran;
								index_i2c := 10;
							end if;	
						end if;
					end if;
						
					
				when ack2_slave	=>
					en_scl_inout_temp := '0';
					pre_scl				:= scl_in_temp;
					scl_in_temp 		:= io_SCL;
					--en_sda_inout_temp := '1';--
					if(pre_scl = '0' and scl_in_temp = '1') then			-- suon len cua scl
						en_sda_inout_temp := '1';
						sda_out_temp 		:= '0';
						frame_i2c(index_i2c):='0';				--frame_i2c(18)=0
						o_data_recv <= frame_i2c(17 downto 10);
						index_i2c := index_i2c+1;		-- index_i2c =19
						state <= stop;
					end if;
					
				when stop =>
					en_scl_inout_temp := '0';
					pre_scl				:= scl_in_temp;
					scl_in_temp 		:= io_SCL;
					--en_sda_inout_temp := '0';
					if(en_temp = '0' and pre_scl = '0' and scl_in_temp = '1') then		-- scl len 1
						en_sda_inout_temp := '0';
						--sda_in_temp := io_SDA;
						en_temp := '1';
					end if;
					if( en_temp = '1' ) then		-- sda len 1
							en_sda_inout_temp := '0';
							sda_in_temp := io_SDA;
							if(sda_in_temp = '1') then
								state <= ready;
								frame_i2c(index_i2c) := '1';
								en_temp := '0';
								index_i2c:=0;
							end if;
						
					end if;
					
					
					
			end case;
			end if;
	
	if(en_state_tran = '0') then
	en_scl_inout	<=	en_scl_inout_temp;
	en_sda_inout	<=	en_sda_inout_temp;
	--sda_in			<=	sda_in_temp;
	sda_out			<= sda_out_temp;
	scl_in			<=	scl_in_temp;
	scl_out			<=	scl_out_temp;
	--pre_sda			<= sda_in;
	--pre_scl			<= scl_in;
	end if;
	--state_temp		<= state;
end process main_process;
end main;