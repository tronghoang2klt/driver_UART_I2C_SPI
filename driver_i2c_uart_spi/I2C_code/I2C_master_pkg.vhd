library ieee;
use ieee.std_logic_1164.all;

package I2C_master_pkg is
	-------in put --------
	type i_line is record
		i_CLK	:std_logic;
		i_perscale	: integer;
	end record i_line;
	
	--- out put------
	type o_line is record
		o_SDA: std_logic;
		o_SCL	: std_logic;
	end record o_line;
	constant i_line_unit	:i_line	:=(i_CLK => '1',
												i_perscale => 5208);
	constant o_line_unit	:o_line	:=(o_SDA=> '1',
												o_SCL => '1');
	end package I2C_master_pkg;