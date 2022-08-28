library ieee;
use 	ieee.std_logic_1164.all;
library std;
use std.standard.all;
library work;
use work.all;

entity Master_I2C is port (
	i_en		: in std_logic;
	i_clk		: in std_logic;
	i_addr		: in std_logic_vector ( 6 downto 0);
	i_wr		: in std_logic;
	i_data_tran	: in std_logic_vector(7 downto 0);
	o_data_recv	: out std_logic_vector(7 downto 0);
	o_comple		: out std_logic:='0';---0 dont cmplement, 1 complement
	io_SDA	: inout std_logic;
	io_SCL	: inout std_logic
	
);
end Master_I2C;

architecture main of Master_I2C is
	signal sda_out			: std_logic:='1';
	signal sda_in			: std_logic:='1';
	signal en_sda_inout	: std_logic:='1';-- 1 out, 0 in
	signal scl_out			: std_logic:='1';
	signal scl_in			: std_logic:='1';
	signal en_scl_inout	: std_logic:='1';-- 1 out, 0 in
	signal perscale		: integer range 0 to 5210:=12;
	
	type 	 state_I2C	is (ready,start,addr,wr,ack1,data_tran,data_recv,ack2_master,ack2_slave,stop);
	--signal state_temp : state_I2C:=ready;
	signal state	: state_I2C:=ready;
begin
	io_SDA <= sda_out when en_sda_inout = '1' else 'Z';
	io_SCL <= scl_out when en_scl_inout = '1' else 'Z';
process(i_clk,i_en,io_SCL)
	variable frame_i2c	: std_logic_vector (19 downto 0);
	variable index_i2c	: integer range 0 to 19:=0; 
	variable en_recv		: std_logic := '0';
	variable	comple_temp	: std_logic := '0';
	variable en_temp 		: std_logic :='0';
	variable en_temp_3 		: std_logic :='0';
	variable	en_state_revc	:std_logic	:= '0';
	variable count 		: integer range 0 to 5210 :=0;
	--variable state	: state_I2C:=ready;
	variable time_repeat	: integer range 0 to 2:=0;
	variable sda_out_temp			: std_logic:='1';
	variable sda_in_temp			: std_logic:='1';
	variable en_sda_inout_temp	: std_logic:='1';-- 1 out, 0 in
	variable scl_out_temp			: std_logic:='1';
	variable scl_in_temp			: std_logic:='1';
	variable en_scl_inout_temp	: std_logic:='1';-- 1 out, 0 in
begin
	if(i_en = '0' ) then		-- co tin hieu truyen hoac da truyen xong
		-- cho SCL va SDA =1
		en_sda_inout_temp := '1';
		sda_out_temp := '1';
		en_scl_inout_temp := '1';
		scl_out_temp := '1';
		state <= ready;
		comple_temp := '0';	
	elsif (en_state_revc = '1') then
		en_state_revc := '0';
		en_scl_inout_temp := '0';
		
	elsif(comple_temp = '0') then
			if(rising_edge (i_clk)) then
				count := count +1;
				
			
			
			case state is
				when ready 	=>
					index_i2c := 0;
					frame_i2c(0):='0';					-- start
					frame_i2c(7 downto 1 ) := i_addr;	--address
					frame_i2c(8)	:= i_wr;			-- write/read
					-- frame_i2c(9) is ack1
					frame_i2c(19)	:= '1';				-- stop
					state <= start;
					count :=0;
					
				when start 	=>
					en_sda_inout_temp := '1';
					sda_out_temp := frame_i2c(index_i2c);
					
					if(count = 3) then
						en_scl_inout_temp := '1';
						scl_out_temp	:= '0';
						state	<= addr;
						count := 0;
						index_i2c := index_i2c+1;
					end if;
					
				when addr	=>
					if(count = perscale/2) then
							en_scl_inout_temp := '1';
							scl_out_temp := '1';
							en_sda_inout_temp := '1';
							sda_out_temp := frame_i2c(index_i2c);
							index_i2c := index_i2c +1;
					elsif ( count = perscale ) then
						scl_out_temp := '0';
						count := 0;
						if ( index_i2c = 8 ) then
							state <= wr;
						end if;
					end if;
					
				when wr		=>
					if(count = perscale/2) then
						en_scl_inout_temp	:= '1';
						scl_out_temp 		:= '1';
						
						en_sda_inout_temp := '1';
						sda_out_temp := frame_i2c(index_i2c);-- frame_i2c(8)
						index_i2c := index_i2c +1;					-- index_i2c = 9;
						
					elsif ( count = perscale ) then
						en_scl_inout_temp	:= '1';
						scl_out_temp := '0';
						count := 0;
						if ( index_i2c = 9 ) then
							state <= ack1;
							
						end if;
					end if;
					
				when ack1	=>
					if(count = perscale/2) then
						en_scl_inout_temp	:= '1';
						scl_out_temp := '1';
						en_sda_inout_temp := '0';			-- high Z + tro keo len = 1
						--index_i2c := index_i2c +1;		-- index_i2c = 10
						--sda_in <= io_SDA;				-- tuc la phan cung no se noi voi nghau
						
					elsif ( count = perscale ) then
						scl_out_temp := '0';
						count := 0;
						--sda_in_temp := io_SDA;
						--- dung dia chi-----
						if(sda_in_temp = '0') then--- co phan hoi
							frame_i2c(9):='0';
							index_i2c := index_i2c +1;		-- index_i2c = 10
							if( frame_i2c(8) = '0') then	-- write
								frame_i2c (17 downto 10) := i_data_tran;
								state <= data_tran;
							else						-- read
								state <= data_recv;
								en_state_revc:='1';
							end if;
						--- khong dung dia chi
						else				-- khong co phan hoi
							state <= stop;
							frame_i2c(9) := '1';
						end if;
					elsif (count > perscale/2 ) then
						en_sda_inout_temp := '0';			-- high Z + tro keo len = 1
						--index_i2c := index_i2c +1;		-- index_i2c = 10
						sda_in_temp := io_SDA;				-- tuc la phan cung no se noi voi nghau
					end if;
					
				when data_tran	=>
					
					if(count = perscale/2) then
						scl_out_temp := '1';
						en_sda_inout_temp := '1';
						sda_out_temp := frame_i2c(index_i2c);
						index_i2c := index_i2c +1;
						
					elsif ( count = perscale ) then
						scl_out_temp := '0';
						count := 0;
						if ( index_i2c = 18 ) then
							state <= ack2_slave;
						end if;
					end if;
					
				when data_recv	=>
					-- lan dau vao, tha noi dau vao
					if(en_temp_3 = '0' and en_recv = '0') then -- lan dau vao
						en_scl_inout_temp	:= '0';
						scl_in_temp			:= io_SCL;
						en_sda_inout_temp := '0';
					
					-- doi slave  keo SCL len 1
						if(en_recv = '0'  and scl_in_temp = '1' ) then -- slave da keo SCL len 1
							en_recv	:= '1';
							-- danh quyen phat SCL lai
							en_scl_inout_temp	:= '1';
							scl_out_temp := '1';
							count	:= perscale /2 +1 ;
							en_temp_3	:= '1';
							-- doc du lieu tu sda 
							en_sda_inout_temp := '0';
						
						end if;
					end if;	
					if(en_recv = '1' ) then
					
						en_sda_inout_temp := '0';
						sda_in_temp := io_SDA;
						
						if(count = perscale/2) then
							en_scl_inout_temp	:= '1';
							scl_out_temp := '1';
							
						elsif ( count = perscale ) then
							en_scl_inout_temp	:= '1';
							scl_out_temp := '0';
							
							en_sda_inout_temp := '0';
							sda_in_temp := io_SDA;
							frame_i2c(index_i2c) := sda_in_temp;
							index_i2c := index_i2c +1;
							count := 0;
							if ( index_i2c = 18 ) then
								state <= ack2_master;
								en_temp_3	:= '0';
								en_recv := '0';
							end if;
						end if;
					
					end if;
					
				when ack2_master =>
					
					if(count = perscale/2) then
						en_scl_inout_temp		:= '1';
						scl_out_temp 			:= '1';
						
						en_sda_inout_temp 	:= '1';
						sda_out_temp 			:= '0';					-- da nhan du du lieu
						
						frame_i2c(index_i2c)	:= '0';
						o_data_recv <= frame_i2c(17 downto 10);
						--index_i2c := index_i2c +1;		-- index_i2c = 19
						
						
					elsif ( count = perscale ) then
						en_scl_inout_temp	:= '1';
						scl_out_temp := '0';
						count := 0;
						state <= stop;
					end if;
					
				when ack2_slave	 =>
					--en_sda_inout_temp := '0';
					if(count = perscale/2) then
						scl_out_temp := '1';
						en_sda_inout_temp := '0';
						--en_sda_inout_temp := '0';			-- high Z + tro keo len = 1
						--index_i2c := index_i2c +1;		-- index_i2c = 19
						--sda_in_temp := io_SDA;				-- tuc la phan cung no se noi voi nghau
				
					elsif ( count = perscale ) then
						scl_out_temp := '0';
						count := 0;
						
						if(sda_in_temp = '0') then--- co phan hoi
							state <= stop;
							frame_i2c(index_i2c):='0';
							index_i2c := index_i2c +1;		-- index_i2c = 19
						else				-- khong co phan hoi
							if(time_repeat = 2) then
								state <= stop;
								time_repeat := 0;
							else
								state <= data_tran;
								index_i2c := 10;
								time_repeat := time_repeat +1;
							end if;
						end if;
					elsif (count > perscale /2 ) then
						en_sda_inout_temp := '0';
						sda_in_temp := io_SDA;
					end if;
					
				when stop =>
					if(count = perscale/2) then
						en_scl_inout_temp := '1';
						scl_out_temp := '1';
						en_temp := '1';
						en_sda_inout_temp	:= '1';
						sda_out_temp	:= frame_i2c(18);
					
					elsif(en_temp = '1') then
						en_sda_inout_temp := '1';
						--sda_out_temp := frame_i2c(index_i2c);--index_i2c= 19
						sda_out_temp	:='1';
						frame_i2c(19)	:= '1';
						state	<= ready;
						comple_temp := '1';	-- da truyen xong
						count := 0;
						index_i2c :=0;
						en_temp := '0';
					end if;
			end case;
			
	end if;
	end if;
	o_comple 		<= comple_temp;
	en_scl_inout	<=	en_scl_inout_temp;
	en_sda_inout	<=	en_sda_inout_temp;
	sda_in			<=	sda_in_temp;
	sda_out			<= sda_out_temp;
	scl_in			<=	scl_in_temp;
	scl_out			<=	scl_out_temp;
	--state_temp		<= state;
end process;
end main;