-------------------------------------------------------------------------------
--
-- Title       : instruction_buffer_tb
-- Design      : pipedlined_simd_multimedia_unit
-- Author      : Huabin Wu
-- Company     : Stony Brook University
--
-------------------------------------------------------------------------------
--
-- File        : C:/My_Designs/pipelined_simd_multimedia_unit/pipedlined_simd_multimedia_unit/src/instruction_buffer_tb.vhd
-- Generated   : Thu Nov 28 21:15:25 2024
-- From        : Interface description file
-- By          : ItfToHdl ver. 1.0
--
-------------------------------------------------------------------------------
--
-- Description : 
--
-------------------------------------------------------------------------------

--{{ Section below this comment is automatically maintained
--    and may be overwritten
--{entity {instruction_buffer_tb} architecture {tb_architecture}}

library ieee;
use work.all;
use std.textio.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

ENTITY instruction_buffer_tb IS
END instruction_buffer_tb;

--}} End of automatically maintained section

ARCHITECTURE tb_architecture OF instruction_buffer_tb IS

	CONSTANT clk_period : TIME := 10 ns;
	-- Signals to connect to UUT
	SIGNAL clk : STD_LOGIC := '0';
	SIGNAL reset : STD_LOGIC := '0';
	SIGNAL PC : STD_LOGIC_VECTOR(5 DOWNTO 0);
	SIGNAL instruction : STD_LOGIC_VECTOR(24 DOWNTO 0) := (OTHERS => '0');
	SIGNAL instruction_out : STD_LOGIC_VECTOR(24 DOWNTO 0);
	SIGNAL read_register1 : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL read_register2 : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL read_register3 : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL write_register : STD_LOGIC_VECTOR(4 DOWNTO 0);
	-- File handling
	FILE instruction_file : text OPEN read_mode IS "output_instructions.txt";
	
BEGIN

	-- Enter your statements here --
	-- Instantiate the Unit Under Test (UUT)
	uut : entity instruction_buffer_module
	PORT MAP(
		clk => clk,
		reset => reset,
		PC => PC,
		instruction => instruction,
		instruction_out => instruction_out,
		read_register1 => read_register1,
		read_register2 => read_register2,
		read_register3 => read_register3,
		write_register => write_register
	);

	-- Clock process definition
	clk_process : PROCESS
	BEGIN
		WHILE true LOOP
			clk <= '0';
			WAIT FOR clk_period / 2;
			clk <= '1';
			WAIT FOR clk_period / 2;
		END LOOP;
	END PROCESS;

	-- Stimulus process
	stim_process : PROCESS
		VARIABLE read_instruction : STD_LOGIC_VECTOR(24 DOWNTO 0);
		VARIABLE line_content : line;
	BEGIN
		-- Reset the system
		reset <= '1';
		WAIT FOR 20 ns;
		reset <= '0';

		-- Load instructions from file
		WHILE NOT endfile(instruction_file) LOOP
			readline(instruction_file, line_content);
			read(line_content, read_instruction);
			instruction <= read_instruction;

			-- Wait for one clock cycle
			WAIT FOR clk_period;
		END LOOP;

		-- Finish simulation
		WAIT;
	END PROCESS;

END tb_architecture;