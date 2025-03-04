-------------------------------------------------------------------------------
--
-- Title       : multimedia_alu_op_execute_TB
-- Design      : pipedlined_simd_multimedia_unit
-- Author      : Huabin Wu, Ryan Lin
-- Company     : Stony Brook University
--
-------------------------------------------------------------------------------
--
-- File        : C:/My_Designs/pipelined_simd_multimedia_unit/pipedlined_simd_multimedia_unit/src/multimedia_alu_op_execute_TB.vhd
-- Generated   : Wed Oct 30 11:45:55 2024
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
--{entity {multimedia_alu_op_execute_TB} architecture {tb_architecture}}

library IEEE; 
use IEEE.std_logic_1164.all;  										  
use IEEE.numeric_std.all;
use work.all;	

entity multimedia_alu_op_execute_TB is
end multimedia_alu_op_execute_TB;

architecture tb_architecture of multimedia_alu_op_execute_TB is
	-- Signal declarations
	signal rd_out : std_logic_vector(127 downto 0); -- rd output register
    signal rs1_in : std_logic_vector(127 downto 0) := X"00000000000000000000000000000000"; -- rs1 input register
    signal rs2_in : std_logic_vector(127 downto 0) := X"00000000000000000000000000000000"; -- rs2 input register
    signal rs3_in : std_logic_vector(127 downto 0) := X"00000000000000000000000000000000"; -- rs3 input register
    signal instruction_in : std_logic_vector(24 downto 0); -- instruction signal
    signal alu_op : std_logic_vector(9 downto 0) := "0000000000"; -- ALU operation signal
	
	signal clk : STD_LOGIC;
begin
	-- Instantiate the Unit Under Test (UUT)
	UUT : entity work.multimedia_alu_op_execute
	port map (		
		clk => clk,
		rd => rd_out,
		rs1 => rs1_in,
		rs2 => rs2_in,
		rs3 => rs3_in,
		instruction => instruction_in
		--operation => alu_op
	);
	
	-- Test Process
	test_process: process
	--variable rd_out_test : std_logic_vector(127 downto 0); -- rd output register for test
	variable product_32, result_32 : signed(32 downto 0);
	variable product_64, result_64 : signed(64 downto 0);
	variable product_32_unsigned : unsigned(63 downto 0);
	variable temp_32 : signed(31 downto 0);
	variable temp_64 : signed(63 downto 0);
	variable expected_values : std_logic_vector(127 downto 0);
	constant MAX_64_SIGNED : signed(63 downto 0) := x"7FFFFFFFFFFFFFFF";
	constant MIN_64_SIGNED : signed(63 downto 0) := x"8000000000000000";
	variable result_16 : signed(16 downto 0);
	variable temp_16 : signed(15 downto 0);
	begin
		-- -- Initialize rd_out_test to zero
		-- reset <= '1';
		-- wait for 1 ns;
		-- reset <= '0';
		-- wait for 1 ns; 
--		instruction_in <= "1000000000000010001000011";		
--		rs1_in <= X"000000004BCD1100000000007000FFFF";
--		rs2_in <= X"00000000000000080000000000007fff";
--		rs3_in <= X"00000000000000020000000000007fff";

		------------------------------------------------------------------
		-- 4.1 Load Immediate
		------------------------------------------------------------------

	    -- Test Case 1.1
--	    instruction_in <= "0000111111111111111100000"; -- 0||000||1111111111111111||00000
--	    wait for 10 ns;
--	    assert (rd_out(15 downto 0) = X"FFFF") report "Test Case 1.1 Failed" severity error;	
--
--	    -- Test Case 1.2
--	    instruction_in <= "0001111111111111111100001"; -- 0||001||1111111111111111||00001
--	    wait for 10 ns;
--	    assert (rd_out(31 downto 16) = X"FFFF") report "Test Case 1.2 Failed" severity error;	
--	    
--		-- Test Case 1.3
--		instruction_in <= "0111111111111111111100100"; -- 0||111||1111111111111111||00100
--		wait for 10 ns;
--	    assert (rd_out(127 downto 112) = X"FFFF") report "Test Case 1.3 Failed" severity error;
--
--		-- Test Case 1.4
--		instruction_in <= "0110111111111111111110000"; -- 0||110||1111111111111111||10000
--		wait for 10 ns;
--	    assert (rd_out(111 downto 96) = X"FFFF") report "Test Case 1.4 Failed" severity error;
		
		------------------------------------------------------------------
		-- 4.2 Multiply-Add and Multiply-Subtract R4-Instruction Format
		------------------------------------------------------------------

		-- -- Test Case 2 [Signed Integer Multiply-Add Low with Saturation]
		-- rs1_in <= X"800000007FFFFFFF00004321000B000C"; --8000 0000 |7FFF FFFF |0000 4321 |000B 000C 
		-- rs2_in <= X"F004FFF8000B7FFFFF00777B11129999"; --F004 FFF8 |000B 7FFF |FF00 777B |1112 9999
		-- rs3_in <= X"E004000800017FFF7FFF044400227FFF"; --E004 0008 |0001 7FFF |7FFF 0444 |0022 7FFF 	
--		rs1_in <= X"000000004BCD1100000000007000FFFF";
--		rs2_in <= X"00000000000000080000000000007fff";
--		rs3_in <= X"00000000000000020000000000007fff";
--		
--		 instruction_in <= "1000000000000000000000000"; -- 10||000||XXXXX||XXXXX||XXXXX||XXXXX
--		  -- Calculate expected values
--		  wait for 10 ns;
--		  for i in 0 to 3 loop
--		 	product_32 := resize((signed(rs3_in((i+1) * 32 - 17 downto i*32)) * signed(rs2_in((i+1) * 32 - 17 downto i*32))), 33);
--			
--             result_32 := product_32 + signed(rs1_in((i+1)*32-1 downto i*32));
--             -- Apply saturation
--             if result_32 > to_signed(2147483647, 33) then 
--		 		temp_32 := to_signed(2147483647, 32);
--		 	elsif result_32 < to_signed(-2147483648, 33) then 
--		 		temp_32 := to_signed(-2147483648, 32);
--		 	else 
--		 		temp_32 := resize(result_32, 32);
--		 	end if;
--
--             -- Store the expected result
--             expected_values((i+1)*32-1 downto i*32) := std_logic_vector((temp_32));
--
--		 	assert (rd_out((i+1)*32-1 downto i*32) = expected_values((i+1)*32-1 downto i*32))
--		 	report "Test Case 2 Failed for field " & integer'image(i) & ". Expected value: " & to_hstring(expected_values((i+1)*32-1 downto i*32)) & ", Actual value: " & to_hstring(rd_out((i+1)*32-1 downto i*32)) severity error;
--		 end loop;

		-- -- Test Case 3 [Signed Integer Multiply-Add High with Saturation]
		-- instruction_in <= "1000100000000000000000000"; -- 10||000||XXXXX||XXXXX||XXXXX||XXXXX
		-- wait for 10 ns;
		-- for i in 0 to 3 loop
		-- 	product_32 := resize((signed(rs3_in((i+1) * 32 - 1 downto (i+1)*32 -16)) * signed(rs2_in((i+1) * 32 - 1 downto (i+1)*32 -16))), 33);
		-- 	result_32 := product_32 + signed(rs1_in((i+1)*32-1 downto i*32));
		-- 	-- Apply saturation
		-- 	if result_32 > to_signed(2147483647, 33) then 
		-- 		temp_32 := to_signed(2147483647, 32);
		-- 	elsif result_32 < to_signed(-2147483648, 33) then
		-- 		temp_32 := to_signed(-2147483648, 32);
		-- 	else 
		-- 		temp_32 := resize(result_32, 32);
		-- 	end if;
		-- 	-- Store the expected result
		-- 	expected_values((i+1)*32-1 downto i*32) := std_logic_vector((temp_32));

		-- 	assert (rd_out((i+1)*32-1 downto i*32) = expected_values((i+1)*32-1 downto i*32))
		-- 	report "Test Case 3 Failed for field " & integer'image(i) & ". Expected value: " & to_hstring(expected_values((i+1)*32-1 downto i*32)) & ", Actual value: " & to_hstring(rd_out((i+1)*32-1 downto i*32)) severity error;
		-- end loop;

--		-- Test Case 4 [Signed Integer Multiply-Subtract Low with Saturation]
		-- rs1_in <= X"800000007FFFFFFF00004321000B000C"; --8000 0000 |7FFF FFFF |0000 4321 |000B 000C 
		-- rs2_in <= X"F004FFF8000B7FFFFF00777B11129999"; --F004 FFF8 |000B 7FFF |FF00 777B |1112 9999
		-- rs3_in <= X"E004000800017FFF7FFF044400227FFF"; --E004 0008 |0001 7FFF |7FFF 0444 |0022 7FFF 
--		instruction_in <= "1001000000000000000000000"; -- 10||010||XXXXX||XXXXX||XXXXX||XXXXX
--		wait for 10 ns;
--		for i in 0 to 3 loop
--			product_32 := resize((signed(rs3_in((i+1) * 32 - 17 downto i*32)) * signed(rs2_in((i+1) * 32 - 17 downto i*32))), 33);
--			result_32 := signed(rs1_in((i+1)*32-1 downto i*32)) - product_32;
--			-- Apply saturation
--			if result_32 > to_signed(2147483647, 33) then 
--				temp_32 := to_signed(2147483647, 32);
--			elsif result_32 < to_signed(-2147483648, 33) then
--				temp_32 := to_signed(-2147483648, 32);
--			else 
--				temp_32 := resize(result_32, 32);
--			end if;
--			-- Store the expected result
--			expected_values((i+1)*32-1 downto i*32) := std_logic_vector((temp_32));
--
--			assert (rd_out((i+1)*32-1 downto i*32) = expected_values((i+1)*32-1 downto i*32))
--			report "Test Case 4 Failed for field " & integer'image(i) & ". Expected value: " & to_hstring(expected_values((i+1)*32-1 downto i*32)) & ", Actual value: " & to_hstring(rd_out((i+1)*32-1 downto i*32)) severity error;
--		end loop;

		 -- Test Case 5 [Signed Integer Multiply-Subtract High with Saturation]
		--  rs1_in <= X"800000007FFFFFFF00004321000B000C"; --8000 0000 |7FFF FFFF |0000 4321 |000B 000C 
		--  rs2_in <= X"F004FFF8000B7FFFFF00777B11129999"; --F004 FFF8 |000B 7FFF |FF00 777B |1112 9999
		--  rs3_in <= X"E004000800017FFF7FFF044400227FFF"; --E004 0008 |0001 7FFF |7FFF 0444 |0022 7FFF 
		--  instruction_in <= "1001100000000000000000000"; -- 10||011||XXXXX||XXXXX||XXXXX||XXXXX
		--  wait for 10 ns;
		--  for i in 0 to 3 loop
		--  	product_32 := resize((signed(rs3_in((i+1) * 32 - 1 downto (i+1)*32 -16)) * signed(rs2_in((i+1) * 32 - 1 downto (i+1)*32 -16))), 33);
		--  	result_32 := signed(rs1_in((i+1)*32-1 downto i*32)) - product_32;
		--  	-- Apply saturation
		--  	if result_32 > to_signed(2147483647, 33) then 
		--  		temp_32 := to_signed(2147483647, 32);
		--  	elsif result_32 < to_signed(-2147483648, 33) then
		--  		temp_32 := to_signed(-2147483648, 32);
		--  	else 
		--  		temp_32 := resize(result_32, 32);
		--  	end if;
		--  	-- Store the expected result
		--  	expected_values((i+1)*32-1 downto i*32) := std_logic_vector((temp_32));

		--  	assert (rd_out((i+1)*32-1 downto i*32) = expected_values((i+1)*32-1 downto i*32))
		--  	report "Test Case 5 Failed for field " & integer'image(i) & ". Expected value: " & to_hstring(expected_values((i+1)*32-1 downto i*32)) & ", Actual value: " & to_hstring(rd_out((i+1)*32-1 downto i*32)) severity error;
		--  end loop;
		
		-- -- Test Case 6 [Signed Long Integer Multiply-Add Low with Saturation]
		-- rs1_in <= X"800000007FFFFFFF100000000000000F"; --8000 0000 7FFF FFFF |1000 0000 0000 000F 
		-- rs2_in <= X"F004FFF8090B7FFF1000000110000001"; --F004 FFF8 090B 7FFF |1000 0001 1000 0001
		-- rs3_in <= X"E004000800017FFFFFFFFFFFFFF2FFFF"; --E004 0008 0001 7FFF |FFFF FFFF FFF2 FFFF
		-- instruction_in <= "1010000000000000000000000"; -- 10||100||XXXXX||XXXXX||XXXXX||XXXXX
		-- wait for 10 ns;
		-- for i in 0 to 1 loop
		-- 	product_64 := resize((signed(rs3_in((i+1) * 64 - 33 downto i*64)) * signed(rs2_in((i+1) * 64 - 33 downto i*64))), 65);
		-- 	result_64 := product_64 + signed(rs1_in((i+1)*64-1 downto i*64));
		-- 	-- Apply saturation
		-- 	if result_64 > MAX_64_SIGNED then 
		-- 		temp_64 := MAX_64_SIGNED;
		-- 	elsif result_64 < MIN_64_SIGNED then
		-- 		temp_64 := MIN_64_SIGNED;
		-- 	else 
		-- 		temp_64 := resize(result_64, 64);
		-- 	end if;
		-- 	-- Store the expected result
		-- 	expected_values((i+1)*64-1 downto i*64) := std_logic_vector((temp_64));

		-- 	assert (rd_out((i+1)*64-1 downto i*64) = expected_values((i+1)*64-1 downto i*64))
		-- 	report "Test Case 6 Failed for field " & integer'image(i) & ". Expected value: " & to_hstring(expected_values((i+1)*64-1 downto i*64)) & ", Actual value: " & to_hstring(rd_out((i+1)*64-1 downto i*64)) severity error;
		-- end loop;

		-- -- Test Case 7 [Signed Long Integer Multiply-Add High with Saturation]
		-- rs1_in <= X"800000007FFFFFFF000000000000000F"; --8000 0000 7FFF FFFF |0000 0000 0000 000F 
		-- rs2_in <= X"F004FFF8000B7FFF0000000100000001"; --F004 FFF8 000B 7FFF |0000 0001 0000 0001
		-- rs3_in <= X"E004000800017FFFFFFFFFFFFFFFFFFF"; --E004 0008 0001 7FFF |FFFF FFFF FFFF FFFF
		-- instruction_in <= "1010100000000000000000000"; -- 10||101||XXXXX||XXXXX||XXXXX||XXXXX
		-- wait for 10 ns;	
		-- for i in 0 to 1 loop
		-- 	product_64 := resize((signed(rs3_in((i+1) * 64 - 1 downto (i+1)*64 -32)) * signed(rs2_in((i+1) * 64 - 1 downto (i+1)*64 -32))), 65);
		-- 	result_64 := product_64 + resize(signed(rs1_in((i+1)*64-1 downto i*64)), 65);
			
		-- 	-- Apply saturation
		-- 	if result_64 >  MAX_64_SIGNED then 
		-- 		temp_64 :=  MAX_64_SIGNED;
		-- 	elsif result_64 < MIN_64_SIGNED then
		-- 		temp_64 := MIN_64_SIGNED;
		-- 	else 
		-- 		temp_64 := resize(result_64, 64);
		-- 	end if;
		-- 	-- Store the expected result
		-- 	expected_values((i+1)*64-1 downto i*64) := std_logic_vector((temp_64));

		-- 	assert (rd_out((i+1)*64-1 downto i*64) = expected_values((i+1)*64-1 downto i*64))
		-- 	report "Test Case 7 Failed for field " & integer'image(i) & ". Expected value: " & to_hstring(expected_values((i+1)*64-1 downto i*64)) & ", Actual value: " & to_hstring(rd_out((i+1)*64-1 downto i*64)) severity error;
		-- end loop;
		-- Test Case 8 [Signed Long Integer Multiply-Subtract Low with Saturation]
		-- rs1_in <= X"800000007FFFFFFF000000000000000F"; --8000 0000 7FFF FFFF |0000 0000 0000 000F 
		-- rs2_in <= X"F004FFF8000B7FFF0000000100000001"; --F004 FFF8 000B 7FFF |0000 0001 0000 0001
		-- rs3_in <= X"E004000800017FFFFFFFFFFFFFFFFFFF"; --E004 0008 0001 7FFF |FFFF FFFF FFFF FFFF
		-- instruction_in <= "1011000000000000000000000"; -- 10||110||XXXXX||XXXXX||XXXXX||XXXXX
		-- wait for 10 ns;
		-- for i in 0 to 1 loop
		-- 	product_64 := resize((signed(rs3_in((i+1) * 64 - 33 downto i*64)) * signed(rs2_in((i+1) * 64 - 33 downto i*64))), 65);
		-- 	result_64 := signed(rs1_in((i+1)*64-1 downto i*64)) - product_64;
		-- 	-- Apply saturation
		-- 	if result_64 >  MAX_64_SIGNED then 
		-- 		temp_64 :=  MAX_64_SIGNED;
		-- 	elsif result_64 < MIN_64_SIGNED then
		-- 		temp_64 := MIN_64_SIGNED;
		-- 	else 
		-- 		temp_64 := resize(result_64, 64);
		-- 	end if;
		-- 	-- Store the expected result
		-- 	expected_values((i+1)*64-1 downto i*64) := std_logic_vector((temp_64));

		-- 	assert (rd_out((i+1)*64-1 downto i*64) = expected_values((i+1)*64-1 downto i*64))
		-- 	report "Test Case 8 Failed for field " & integer'image(i) & ". Expected value: " & to_hstring(expected_values((i+1)*64-1 downto i*64)) & ", Actual value: " & to_hstring(rd_out((i+1)*64-1 downto i*64)) severity error;
		-- end loop;
		-- Test Case 9 [Signed Long Integer Multiply-Subtract High with Saturation]
		-- rs1_in <= X"800000007FFFFFFF000000000000000F"; --8000 0000 7FFF FFFF |0000 0000 0000 000F 
		-- rs2_in <= X"F004FFF8000B7FFF0000000100000001"; --F004 FFF8 000B 7FFF |0000 0001 0000 0001
		-- rs3_in <= X"E004000800017FFFFFFFFFFFFFFFFFFF"; --E004 0008 0001 7FFF |FFFF FFFF FFFF FFFF
		-- instruction_in <= "1011100000000000000000000"; -- 10||111||XXXXX||XXXXX||XXXXX||XXXXX
		-- wait for 10 ns;
		-- for i in 0 to 1 loop
		-- 	product_64 := resize((signed(rs3_in((i+1) * 64 - 1 downto (i+1)*64 -32)) * signed(rs2_in((i+1) * 64 - 1 downto (i+1)*64 -32))), 65);
		-- 	result_64 := signed(rs1_in((i+1)*64-1 downto i*64)) - product_64;
		-- 	-- Apply saturation
		-- 	if result_64 >  MAX_64_SIGNED then
		-- 		temp_64 :=  MAX_64_SIGNED;
		-- 	elsif result_64 < MIN_64_SIGNED then
		-- 		temp_64 := MIN_64_SIGNED;
		-- 	else
		-- 		temp_64 := resize(result_64, 64);
		-- 	end if;
		-- 	-- Store the expected result
		-- 	expected_values((i+1)*64-1 downto i*64) := std_logic_vector((temp_64));

		-- 	assert (rd_out((i+1)*64-1 downto i*64) = expected_values((i+1)*64-1 downto i*64))
		-- 	report "Test Case 9 Failed for field " & integer'image(i) & ". Expected value: " & to_hstring(expected_values((i+1)*64-1 downto i*64)) & ", Actual value: " & to_hstring(rd_out((i+1)*64-1 downto i*64)) severity error;
		-- end loop;
		
		------------------------------------------------------------------
		-- 4.3 Multiply-Add and Multiply-Subtract R4-Instruction Format
		------------------------------------------------------------------

		-- -- Test Case 10 + 11 [nop + shift left halfword immediate]
		-- rs1_in <= X"00011111000100010001000100010001"; -- 0001 1111 0001 0001 0001 0001 0001 0001
		-- instruction_in <= "1110100001000110000000000"; -- 11||xxxx0001||00011||XXXXX||XXXXX
		-- wait for 50 ns;
		-- assert (rd_out = std_logic_vector(signed(rs1_in) sll 3)) 
		-- report "Test Case 10 Failed" severity error;

		-- instruction_in <= "1110100000000110000000000"; -- 11||xxxx0000||XXXXX||XXXXX||XXXXX
		-- wait for 50 ns;
		-- assert (rd_out = rd_out) 
		-- report "Test Case 10 NOP Failed" severity error;

		-- -- Test Case 12 [Add Word Unsigned]:
		-- rs1_in <= X"800000007FFFFFFF000000000000000F"; --8000 0000 |7FFF FFFF |0000 0000 |0000 000F 
		-- rs2_in <= X"F004FFF8000B7FFF0000000100000001"; --F004 FFF8 |000B 7FFF |0000 0001 |0000 0001
		-- instruction_in <= "1110100010000110000000000"; -- 11||xxxx0010||XXXXX||XXXXX||XXXXX
		-- wait for 10 ns;
		-- for i in 0 to 3 loop
		-- 	expected_values((i+1)*32-1 downto i*32) := std_logic_vector(resize(unsigned(rs1_in((i+1)*32-1 downto i*32)) + unsigned(rs2_in((i+1)*32-1 downto i*32)), 32));
		-- 	assert (rd_out((i+1)*32-1 downto i*32) = expected_values((i+1)*32-1 downto i*32))
		-- 	report "Test Case 12 Failed for field " & integer'image(i) & ". Expected value: " & to_hstring(expected_values((i+1)*32-1 downto i*32)) & ", Actual value: " & to_hstring(rd_out((i+1)*32-1 downto i*32)) severity error;
		-- end loop;

		-- -- Test Case 13 [count 1s in halfword]
		 rs1_in <= X"00100100901000000A0000F000200300"; -- 0010 0100 9010 0000 0A00 00F0 0020 0300
		 instruction_in <= "1100000011000000000000000"; -- 11||xxxx0011||XXXXX||XXXXX||XXXXX
		 wait for 10 ns;

		-- -- Test Case 14 [Add halfword saturated]
		-- rs1_in <= X"800000007FFF7FFF000000000000000F"; --8000 0000 7FFF 7FFF 0000 0000 0000 000F
		-- rs2_in <= X"F004FFF8000B7FFF0000000100000001"; --F004 FFF8 000B 7FFF |0000 0001 0000 0001
		-- instruction_in <= "1100000100000000000000000"; -- 11||xxxx0100||XXXXX||XXXXX||XXXXX
		-- wait for 10 ns;
		-- for i in 0 to 7 loop
		-- 	result_16 := resize(signed('0' & rs2_in((i+1) * 16 - 1 downto i*16)) + signed('0' & rs1_in((i+1) * 16 - 1 downto i*16)),17);

		-- 	if result_16 > to_signed(32767, 17) then
		-- 		temp_16 := to_signed(32767, 16);
		-- 	elsif result_16 < to_signed(-32768, 17) then
		-- 		temp_16 := to_signed(-32768, 16);
		-- 	else
		-- 		temp_16 := resize(result_16, 16);
		-- 	end if;
		-- 	-- store the expected result
		-- 	expected_values((i+1)*16-1 downto i*16) := std_logic_vector((temp_16));

		-- 	assert (rd_out((i+1)*16-1 downto i*16) = expected_values((i+1)*16-1 downto i*16))
		-- 	report "Test Case 14 Failed for field " & integer'image(i) & ". Expected value: " & to_hstring(expected_values((i+1)*16-1 downto i*16)) & ", Actual value: " & to_hstring(rd_out((i+1)*16-1 downto i*16)) severity error;
		-- end loop;

		-- -- Test Case 15 [bitwise logical and]
		-- rs1_in <= X"800000007FFFFFFF000000000000000F"; --8000 0000 7FFF FFFF |0000 0000 0000 000F
		-- rs2_in <= X"F004FFF8000B7FFF0000000100000001"; --F004 FFF8 000B 7FFF |0000 0001 0000 0001
		-- instruction_in <= "1100000101000000000000000"; -- 11||xxxx0101||XXXXX||XXXXX||XXXXX
		-- wait for 10 ns;
		-- expected_values := rs1_in and rs2_in;
		
		-- assert (rd_out = expected_values)
		-- report "Test Case 15 Failed. " severity error;

		
		-- -- Test Case 16 [broadcast word]
		-- rs1_in <= X"800000007FFFFFFF000000000000000F"; --8000 0000 7FFF FFFF |0000 0000 0000 000F
		-- instruction_in <= "1100000110000000000000000"; -- 11||xxxx0110||XXXXX||XXXXX||XXXXX
		-- wait for 10 ns;

		-- --Test Case 17 [max signed word]
		-- rs1_in <= X"800000007FFFFFFF000000000000000F"; --8000 0000 7FFF FFFF |0000 0000 0000 000F
		-- rs2_in <= X"F004FFF8000B7FFF0000000100000001"; --F004 FFF8 000B 7FFF |0000 0001 0000 0001
		-- instruction_in <= "1100000111000000000000000"; -- 11||xxxx0111||XXXXX||XXXXX||XXXXX
		-- wait for 10 ns;

		-- --Test Case 18 [min signed word]
		-- rs1_in <= X"800000007FFFFFFF000000000000000F"; --8000 0000 7FFF FFFF |0000 0000 0000 000F
		-- rs2_in <= X"F004FFF8000B7FFF0000000100000001"; --F004 FFF8 000B 7FFF |0000 0001 0000 0001
		-- instruction_in <= "1100001000000000000000000"; -- 11||xxxx1000||XXXXX||XXXXX||XXXXX
		-- wait for 10 ns;

	 	-- --Test Case 19 [multiply low unsigned]
		-- rs1_in <= X"800000007FFFFFFF000000000000000F"; --8000 0000 | 7FFF FFFF |0000 0000 | 0000 000F
		-- rs2_in <= X"F004FFF8000B7FFF0000000100000001"; --F004 FFF8 | 000B 7FFF |0000 0001 | 0000 0001
		-- instruction_in <= "1100001001000000000000000"; -- 11||xxxx1001||XXXXX||XXXXX||XXXXX
		-- wait for 10 ns;

		-- --Test Case 20 [multiply low by constant unsigned]
		-- rs1_in <= X"800000007FFFFFFF000000000000000F"; --8000 0000 | 7FFF FFFF |0000 0000 | 0000 000F
		-- instruction_in <= "1100001010000100000000000"; -- 11||xxxx1010||00010||XXXXX||XXXXX
		-- wait for 10 ns;
		
		-- --Test Case 21 [bitwise logical or]
		-- rs1_in <= X"800000007FFFFFFF000000000000000F"; --8000 0000 7FFF FFFF |0000 0000 0000 000F
		-- rs2_in <= X"F004FFF8000B7FFF0000000100000001"; --F004 FFF8 000B 7FFF |0000 0001 0000 0001
		-- instruction_in <= "1100001011000000000000000"; -- 11||xxxx1011||XXXXX||XXXXX||XXXXX
		-- wait for 10 ns;
		-- expected_values := rs1_in or rs2_in;
		-- assert (rd_out = expected_values)
		-- report "Test Case 21 Failed. " severity error;

		-- --Test Case 22 [count leading zeroes in halfwords]
		-- rs1_in <= X"800000007FFFFFFF000000000000000F"; --8000 0000 7FFF FFFF |0000 0000 0000 000F
		-- instruction_in <= "1100001100000000000000000"; -- 11||xxxx1100||XXXXX||XXXXX||XXXXX
		-- wait for 10 ns;
		
		-- --Test Case 23 [Rotate left bits in halfwords]
		-- instruction_in <= "1100001101000000000000000"; -- 11||xxxx1101||XXXXX||XXXXX||XXXXX	
		-- rs1_in <= X"800000007FFFFFFF000000110000810F"; --8000 0000 7FFF FFFF |0000 0011 0000 810F
		-- rs2_in <= X"F004FFF8000B7FFF0000000200000001"; --F004 FFF8 000B 7FFF |0000 0002 0000 0001
		-- wait for 10 ns;

		-- --Test Case 24 [subtract from word unsigned]
		-- instruction_in <= "1100001110000000000000000"; -- 11||xxxx1110||XXXXX||XXXXX||XXXXX
		-- rs1_in <= X"800000007FFFFFFF000000000000000F"; --8000 0000 7FFF FFFF |0000 0000 0000 000F
		-- rs2_in <= X"F004FFF8000B7FFF0000000100000001"; --F004 FFF8 000B 7FFF |0000 0001 0000 0001
		-- wait for 10 ns;
		-- for i in 0 to 3 loop		
		-- 	expected_values((i+1)*32-1 downto i*32) := std_logic_vector(resize(unsigned(rs2_in((i+1)*32-1 downto i*32)) - unsigned(rs1_in((i+1)*32-1 downto i*32)), 32));
		-- 	assert (rd_out((i+1)*32-1 downto i*32) = expected_values((i+1)*32-1 downto i*32))
		-- 	report "Test Case 24 Failed for field " & integer'image(i) & ". Expected value: " & to_hstring(expected_values((i+1)*32-1 downto i*32)) & ", Actual value: " & to_hstring(rd_out((i+1)*32-1 downto i*32)) severity error;
		-- end loop;

		-- --Test Case 25 [subtract from halfword saturated]
		-- instruction_in <= "1100001111000000000000000"; -- 11||xxxx1111||XXXXX||XXXXX||XXXXX
		-- rs2_in <= X"8000FFF8000B7FFF0000000100000001"; --8000 FFF8 000B 7FFF |0000 0001 0000 0001
		-- rs1_in <= X"700000007FFF8FFF000000000000000F"; --7000 0000 7FFF 8FFF |0000 0000 0000 000F
		-- wait for 10 ns;
		-- for i in 0 to 7 loop
		-- 	result_16 := resize(signed('0' & rs2_in((i+1) * 16 - 1 downto i*16)) - signed('0' & rs1_in((i+1) * 16 - 1 downto i*16)),17);

		-- 	if result_16 > to_signed(32767, 17) then
		-- 		temp_16 := to_signed(32767, 16);
		-- 	elsif result_16 < to_signed(-32768, 17) then
		-- 		temp_16 := to_signed(-32768, 16);
		-- 	else
		-- 		temp_16 := resize(result_16, 16);
		-- 	end if;
		-- 	-- store the expected result
		-- 	expected_values((i+1)*16-1 downto i*16) := std_logic_vector((temp_16));

		-- 	assert (rd_out((i+1)*16-1 downto i*16) = expected_values((i+1)*16-1 downto i*16))
		-- 	report "Test Case 25 Failed for field " & integer'image(i) & ". Expected value: " & to_hstring(expected_values((i+1)*16-1 downto i*16)) & ", Actual value: " & to_hstring(rd_out((i+1)*16-1 downto i*16)) severity error;
		-- end loop;
		
		wait;

		
	end process;	
end tb_architecture;
