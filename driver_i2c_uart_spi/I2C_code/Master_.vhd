library ieee;
use 	ieee.std_logic_1164.all;
library std;
use std.standard.all;
library work;
use work.all;

entity Master_I2C is
port(
	i_clk		:in	std_logic;
	i_enable	:in std_logic
	io_SCL	:inout	std_logic;
	io_SDA	:inout 	std_logic
	
);