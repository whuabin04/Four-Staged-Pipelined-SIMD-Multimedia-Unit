-------------------------------------------------------------------------------
--
-- Title       : instruction_buffer_module
-- Design      : pipedlined_simd_multimedia_unit
-- Author      : Huabin Wu
-- Company     : Stony Brook University
--
-------------------------------------------------------------------------------
--
-- File        : C:/My_Designs/pipelined_simd_multimedia_unit/pipedlined_simd_multimedia_unit/src/instruction_buffer_module.vhd
-- Generated   : Thu Nov 28 14:04:10 2024
-- From        : Interface description file
-- By          : ItfToHdl ver. 1.0
--
-------------------------------------------------------------------------------
--
-- Description : The instruction buffer can store 64 25-bit instructions. The 
-- contents of the buffer should be loaded by the testbench instructions from a test
-- file at the start of simulation. On each cycle, the instruction specified by the
-- Program Counter (PC) is fetched, and the value of PC is incremented by 1.
--
-------------------------------------------------------------------------------

--{{ Section below this comment is automatically maintained
--    and may be overwritten
--{entity {instruction_buffer_module} architecture {behavioral}}

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity instruction_buffer_module is
	port (
		clk : in std_logic;
		reset : in std_logic;
		PC : out std_logic_vector(5 downto 0);
		instruction : in std_logic_vector(24 downto 0);
		instruction_out : out std_logic_vector(24 downto 0);
		read_register1 : out std_logic_vector(4 downto 0) := (others => '0'); 
		read_register2 : out std_logic_vector(4 downto 0) := (others => '0');
		read_register3 : out std_logic_vector(4 downto 0) := (others => '0');
		write_register : out std_logic_vector(4 downto 0) := (others => '0')
	);
end instruction_buffer_module;

--}} End of automatically maintained section

architecture behavioral of instruction_buffer_module is
	type instruction_array is array(63 downto 0) of std_logic_vector(24 downto 0);
    signal instructions : instruction_array := (others => (others => '0'));
	signal PC_reg : integer := 0; -- Program Counter
    signal buffer_index : integer range 0 to 63 := 0; -- Buffer index
begin
	process(clk, reset)
	begin
		if reset = '1' then
			buffer_index <= 0;
		elsif rising_edge(clk) and reset = '0' then
			PC_reg <= PC_reg + 1;
			instructions(buffer_index) <= instruction;
			instruction_out <= instruction;
			buffer_index <= buffer_index + 1;
			if buffer_index = 63 then
				buffer_index <= 0;
			end if;
		end if;
	end process;

	process(clk)
	begin
		if rising_edge(clk) then
			--instruction <= instructions(to_integer(unsigned(PC_reg)));
			read_register1 <= (others => '0');
			read_register2 <= (others => '0');
			read_register3 <= (others => '0');
			write_register <= instruction(4 downto 0); -- rd always in same position
			if instruction(24) = '0' then --LI instruction only RD
				NULL;
			--4.2 Multiply-Add and Multiply-Subtract R4-Instruction Format
			-- 10_opcode_rs3_rs2_rs1_rd 
			elsif instruction(24 downto 23) = "10" then
				read_register1 <= instruction(9 downto 5);
				read_register2 <= instruction(14 downto 10);
				read_register3 <= instruction(19 downto 15);
			elsif instruction(24 downto 23) = "11" then
			-- 4.3   R3-Instruction Format 11_opcode_rs2_rs1_rd
				read_register1 <= instruction(9 downto 5);
				read_register2 <= instruction(14 downto 10);
			end if; 
		end if;	
	end process;

	
end behavioral;
