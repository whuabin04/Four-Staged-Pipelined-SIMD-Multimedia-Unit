-------------------------------------------------------------------------------
--
-- Title       : four_staged_pipelined_mmu
-- Design      : pipedlined_simd_multimedia_unit
-- Author      : Huabin Wu
-- Company     : Stony Brook University
--
-------------------------------------------------------------------------------
--
-- File        : C:/My_Designs/pipelined_simd_multimedia_unit/pipedlined_simd_multimedia_unit/src/four_staged_pipelined_mmu.vhd
-- Generated   : Thu Nov 28 16:02:12 2024
-- From        : Interface description file
-- By          : ItfToHdl ver. 1.0
--
-------------------------------------------------------------------------------
--
-- Description : Clock edge-sensitive pipeline registers separate the IF, ID, EXE, 
-- and WB stages. Data should be written to the Register File after the WB Stage.
-- All instructions (including li) take four cycles to complete. This pipeline must 
-- be implemented as a structural model with modules for each corresponding pipeline 
-- stages and their interstage registers. Four instructions can be at different stages 
-- of the pipeline at every cycle.
--
-------------------------------------------------------------------------------

--{{ Section below this comment is automatically maintained
--    and may be overwritten
--{entity {four_staged_pipelined_mmu} architecture {four_staged_pipelined_mmu}}

library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity four_staged_pipelined_mmu is	
	port(
		clk : in std_logic;
		reset : in std_logic;
		register_write_enable : in std_logic;
		instruction_in : in std_logic_vector(24 downto 0);
		PC : in std_logic_vector(5 downto 0)
		--rd : out std_logic_vector(127 downto 0)
	);
end four_staged_pipelined_mmu;

--}} End of automatically maintained section

architecture structural of four_staged_pipelined_mmu is
	--signals for unit modules
	signal read_reg1_buffer, read_reg2_buffer, read_reg3_buffer, write_reg_buffer : std_logic_vector(4 downto 0) := (others => '0');
	signal read_regdata1, read_regdata2, read_regdata3 : std_logic_vector(127 downto 0);
	signal destination_data : std_logic_vector(127 downto 0);
	signal MMALU_instruction : std_logic_vector(24 downto 0);
	signal MMALU_write_enable : std_logic;
	signal PC_reg : std_logic_vector(5 downto 0);
	signal rd_addr_alu : std_logic_vector(4 downto 0) := (others => '0') ;
	signal mux1_out_data, mux2_out_data, mux3_out_data : std_logic_vector(127 downto 0);
	signal yes_forwarding_pipe : std_logic := '0'; 
begin
	-- instruction_buffer_unit instantiation
	u1 : entity instruction_buffer_module
		port map(
		clk => clk,
		reset => reset,
		instruction => instruction_in,
		instruction_out => MMALU_instruction,
		read_register1 => read_reg1_buffer,
		read_register2 => read_reg2_buffer, 
		read_register3 => read_reg3_buffer,
		write_register => write_reg_buffer
	);
	-- register_module_unit instantiation
	u2 : entity register_module
		port map(
			clk => clk,
			reset => reset,
			write_reg_buffer => write_reg_buffer,
			read_addr1 => read_reg1_buffer,
			read_addr2 => read_reg2_buffer,
			read_addr3 => read_reg3_buffer,
			read_data1 => read_regdata1,
			read_data2 => read_regdata2,
			read_data3 => read_regdata3,
			register_write_addr => rd_addr_alu,
			destination_register_data => destination_data,
			register_write_enable => MMALU_write_enable,
			yes_forwarding => yes_forwarding_pipe,
			destination_data_forwarded => destination_data
	);
	-- forwarding_unit_unit instantiation
	u3 : entity forwarding_unit
		port map(
			clk => clk,
			reset => reset,
			r1_addr => read_reg1_buffer,
			r2_addr => read_reg2_buffer,
			r3_addr => read_reg3_buffer,
			fwrd_rd_addr => rd_addr_alu,
			rd_data => destination_data,
			mux1_out => mux1_out_data,
			mux2_out => mux2_out_data,
			mux3_out => mux3_out_data,
			r1 => read_regdata1, 
			r2 => read_regdata2,
			r3 => read_regdata3,
			valid_data => MMALU_write_enable,
			yes_forwarding => yes_forwarding_pipe
		);
	-- multimedia_alu_ex_unit instantiation
	u4 : entity multimedia_alu_op_execute
		port map(	
			clk => clk,
			rd => destination_data,
			alu_rd_addr => rd_addr_alu,
			instruction => MMALU_instruction,
			rs1 => mux1_out_data,
			rs2 => mux2_out_data,
			rs3 => mux3_out_data,
			alu_to_write_back => MMALU_write_enable
		);
end structural;
