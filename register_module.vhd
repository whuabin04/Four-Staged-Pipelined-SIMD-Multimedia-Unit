-------------------------------------------------------------------------------
--
-- Title       : register_module
-- Design      : pipedlined_simd_multimedia_unit
-- Author      : Huabin Wu
-- Company     : Stony Brook University
--
-------------------------------------------------------------------------------
--
-- File        : C:/My_Designs/pipelined_simd_multimedia_unit/pipedlined_simd_multimedia_unit/src/register_module.vhd
-- Generated   : Thu Nov 28 14:02:03 2024
-- From        : Interface description file
-- By          : ItfToHdl ver. 1.0
--
-------------------------------------------------------------------------------
--
-- Description : The register file has 32 128-bit registers. On any cycle, there 
-- can be 3 reads and 1 write. When executing instructions, each cycle two/three 
-- 128-bit register values are read, and one 128-bit result can be written if a 
-- write signal is valid. This register write signal must be explicitly declared 
-- so it can be checked during simulation and demonstration of your design.
--
-------------------------------------------------------------------------------

--{{ Section below this comment is automatically maintained
--    and may be overwritten
--{entity {register_module} architecture {behavioral}}

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity register_module is
	port(
		clk : in STD_LOGIC; -- Clock
		reset : in STD_LOGIC; -- Reset
		--read ports
		read_addr1 : in std_logic_vector(4 downto 0) := (others => '0'); -- Register1 read
		read_addr2 : in std_logic_vector(4 downto 0) := (others => '0'); -- Register2 read
		read_addr3 : in std_logic_vector(4 downto 0) := (others => '0'); -- Register3 read
		read_data1 : out std_logic_vector(127 downto 0); -- Register1 read data
		read_data2 : out std_logic_vector(127 downto 0); -- Register2 read data
		read_data3 : out std_logic_vector(127 downto 0); -- Register3 read data
		--write ports
		register_write_addr : in std_logic_vector(4 downto 0); -- Register write address
		destination_register_data : in std_logic_vector(127 downto 0); -- Register write data
		register_write_enable : in STD_LOGIC; -- Register write enable  
		write_reg_buffer : in std_logic_vector(4 downto 0) := (others => '0'); -- Register write buffer
		yes_forwarding : in std_logic := '0'; -- Forwarding 0
		destination_data_forwarded : in std_logic_vector(127 downto 0) := (others => '0') -- Forwarded data
	); 
end register_module;
												  
--}} End of automatically maintained section

architecture behavioral of register_module is
	type reg_array is array(31 downto 0) of std_logic_vector(127 downto 0);
	signal registers : reg_array := (others => (others => '0')); -- Initialize to 0
	
begin	  
	process(clk, reset, register_write_enable, read_addr1, read_addr2, read_addr3)
	begin 
		read_data1 <= registers(to_integer(unsigned(read_addr1)));
		read_data2 <= registers(to_integer(unsigned(read_addr2)));
		read_data3 <= registers(to_integer(unsigned(read_addr3)));
		if reset = '1' then
			-- Reset all registers to 0
			registers <= (others => (others => '0'));
			read_data1 <= (others => '0');
			read_data2 <= (others => '0');
			read_data3 <= (others => '0');
		elsif rising_edge(clk) then
			if register_write_enable = '1' then
				-- Write data to the specified register
				registers(to_integer(unsigned(register_write_addr))) <= destination_register_data;
				-- if forwarding is enabled, write to the register buffer
				if yes_forwarding = '1' then
					registers(to_integer(unsigned(write_reg_buffer))) <= destination_data_forwarded;	
				else NULL;
				end if;
			else NULL; 
			end if;	 	
		end if;
	end process;

	-- can you check to see what type of instruction it is from the instruction input
	-- so we can know what registers to read and write
	-- like if it is a load instruction, we only need to write one register from 4:0
	-- if it is a r4.1 instruction format, we read r3, r2, r1 from 19:15, 14:10, 9:5 respectively and write to rd from 4:0
	-- if it is a r4.2 instruction format, we read r2, r1, from 14:10, 9:5 respectively and write to rd from 4:0

end behavioral;
