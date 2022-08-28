library ieee;
use ieee.std_logic_1164.all;
library std;
use std.standard.all;
library work;
use work.all;
entity Main_I2C is 
port(
	i_clk	:in std_logic;
	--i_clk_1	: in std_logic;
	io_SDA:inout std_logic;
	io_SCL: inout std_logic
);
end Main_I2C;
architecture main of Main_I2C is
	signal i_en_master	: 	std_logic:='1';
	signal i_en_slave		:  std_logic:= '1';
	signal i_addr			: 	std_logic_vector( 6 downto 0):= "1101001";
	signal i_addr_slave	:  std_logic_vector( 6 downto 0):= "1101001";
	signal i_wr				:  std_logic:= '0';
	signal i_data_tran_master	:  std_logic_vector(7 downto 0):="10100101";
	signal o_data_recv_master	:  std_logic_vector(7 downto 0);
	signal i_data_tran_slave	:  std_logic_vector(7 downto 0):="11001010";
	signal o_data_recv_slave	:  std_logic_vector(7 downto 0);
	signal o_comple				: 	std_logic:='0';
	
component Master_I2C is port(
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
end component Master_I2C;
component Slave_I2C is port(
	i_en		: in std_logic;								
	i_clk		: in std_logic;
	i_addr	: in std_logic_vector ( 6 downto 0);
	i_data_tran	: in std_logic_vector(7 downto 0);
	o_data_recv	: out std_logic_vector(7 downto 0);
	io_SDA	: inout std_logic;
	io_SCL	: inout std_logic
);
end component Slave_I2C;
begin
U1: Master_I2C port map (i_en_master,i_clk,i_addr,i_wr,i_data_tran_master,o_data_recv_master,o_comple,io_SDA,io_SCL);
U2: Slave_I2C  port map (i_en_slave,i_clk,i_addr_slave,i_data_tran_slave,o_data_recv_slave,io_SDA,io_SCL);
end main;