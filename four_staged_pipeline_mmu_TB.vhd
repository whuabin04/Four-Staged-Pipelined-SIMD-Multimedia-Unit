-------------------------------------------------------------------------------
--
-- Title       : four_staged_pipeline_mmu_TB
-- Design      : pipedlined_simd_multimedia_unit
-- Author      : Huabin Wu
-- Company     : Stony Brook University
--
-------------------------------------------------------------------------------
--
-- File        : C:/My_Designs/pipelined_simd_multimedia_unit/pipedlined_simd_multimedia_unit/src/four_staged_pipeline_mmu_TB.vhd
-- Generated   : Sun Dec  1 03:47:50 2024
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
--{entity {four_staged_pipeline_mmu_TB} architecture {tb_architecture}}

library ieee;
use work.all;
use std.textio.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_textio.all; -- Include this package for to_string function

entity four_staged_pipeline_mmu_TB is
end four_staged_pipeline_mmu_TB;

--}} End of automatically maintained section

architecture tb_architecture of four_staged_pipeline_mmu_TB is
	constant clk_period : time := 10 ns;
	signal clk : std_logic := '0';
	signal reset : std_logic := '0';
	signal PC : std_logic_vector(5 downto 0) := "000000";
	signal instruction_in : std_logic_vector(24 downto 0) := (others => '0');
	signal register_write_enable : std_logic := '1';
	signal rd : std_logic_vector(127 downto 0);
	FILE instruction_file : text OPEN read_mode IS "output_instructions.txt";
	FILE results_file : text OPEN write_mode IS "results_file.txt";

	
begin
	UUT : entity work.four_staged_pipelined_mmu
	port map(
		clk => clk,
		reset => reset,	   
		PC => PC,
		register_write_enable => register_write_enable,
		instruction_in => instruction_in
		--rd => rd
	);		 
	
	clk_process : PROCESS
	BEGIN
		WHILE true LOOP
			clk <= '0';
			WAIT FOR clk_period / 2;
			clk <= '1';
			WAIT FOR clk_period / 2;
		END LOOP;
	END PROCESS;

	instruction : process
		variable line_content : line;
		variable read_instruction : std_logic_vector(24 downto 0);
	begin
	-- Reset the system
		reset <= '1';
		WAIT FOR 14 ns;
		reset <= '0';	 
		
		while not endfile(instruction_file) loop
			readline(instruction_file, line_content);
			read(line_content, read_instruction);
			instruction_in <= read_instruction;
  
		  	wait for clk_period;
--			 -- Write results to file
--                 -- Write results to file
--				write(line_content, string'("Instruction: "));
--				write(line_content, instruction_in);
--				writeline(results_file, line_content);
--	 
--				 -- Write opcode, operands, results, and control signals
--				if instruction_in(24) = '0' then -- If instruction is a load
--					write (line_content, string'("Opcode: "));
--					write (line_content, string'("LI"));
--					writeline(results_file, line_content);
--
--					write (line_content, string'("Load index: "));
--					write(line_content, to_string(to_integer(unsigned(instruction_in(23 downto 21)))));					
--					writeline(results_file, line_content);
--
--					write (line_content, string'("Immediate value: "));
--					write (line_content, to_string(to_integer(unsigned(instruction_in(20 downto 5)))));
--					writeline(results_file, line_content);
--
--					write (line_content, string'("RD: "));
--					write (line_content, to_string(to_integer(unsigned(instruction_in(4 downto 0)))));
--					writeline(results_file, line_content);
--
--					write(line_content, string'("Result: "));
--					write(line_content, rd);
--					writeline(results_file, line_content);
--
--					writeline(results_file, line'(""));
--					writeline(results_file, line'(""));
--
--				end if;
--
--				if instruction_in(24 downto 23) then
--					write (line_content, string'("Opcode: "));
--					write (line_content, instruction_in(22 downto 20));
--					writeline(results_file, line_content);
--
--					write (line_content, string'("RS3: "));
--					write (line_content, tostring(to_integer(unsigned(instruction_in(19 downto 15)))));
--					writeline(results_file, line_content);
--
--					write (line_content, string'("RS2: "));
--					write (line_content, tostring(to_integer(unsigned(instruction_in(14 downto 10)))));
--					writeline(results_file, line_content);
--
--					write (line_content, string'("RS1: "));
--					write (line_content, tostring(to_integer(unsigned(instruction_in(9 downto 5)))));
--					writeline(results_file, line_content);
--
--					write (line_content, string'("RD: "));
--					write (line_content, tostring(to_integer(unsigned(instruction_in(4 downto 0)))));
--					writeline(results_file, line_content);
--
--					write (line_content, string'("Result: "));
--					write (line_content, rd);
--					writeline(results_file, line_content);
--					writeline(results_file, line'(""));
--					writeline(results_file, line'(""));
--
--
--				end if;
--
--				if instruction_in(24 downto 23) = "01" then -- If instruction is a r3
--					write (line_content, string'("Opcode: "));
--					write (line_content, instruction_in(22 downto 15));
--					writeline(results_file, line_content);
--
--					write (line_content, string'("RS2: "));
--					write (line_content, tostring(to_integer(unsigned(instruction_in(14 downto 10)))));
--					writeline(results_file, line_content);
--
--					write (line_content, string'("RS1: "));
--					write (line_content, tostring(to_integer(unsigned(instruction_in(9 downto 5)))));
--					writeline(results_file, line_content);
--
--					write (line_content, string'("RD: "));
--					write (line_content, tostring(to_integer(unsigned(instruction_in(4 downto 0)))));
--					writeline(results_file, line_content);
--
--					write (line_content, string'("Result: "));
--					write (line_content, rd);
--					writeline(results_file, line_content);
--					writeline(results_file, line'(""));
--					writeline(results_file, line'(""));
--
--				end if;
		end loop;	
--		file_close(results_file);		   
--		wait;
	end process;  

end tb_architecture;