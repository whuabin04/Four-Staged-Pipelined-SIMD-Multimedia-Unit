-------------------------------------------------------------------------------
--
-- Title       : multimedia_alu_op_execute
-- Design      : pipedlined_simd_multimedia_unit
-- Author      : Huabin Wu, Ryan Lin
-- Company     : Stony Brook University
--
-------------------------------------------------------------------------------
--
-- File        : c:/My_Designs/pipelined_simd_multimedia_unit/pipedlined_simd_multimedia_unit/src/multimedia_alu_op_execute.vhd
-- Generated   : Sat Oct 26 18:49:36 2024
-- From        : Interface description file
-- By          : ItfToHdl ver. 1.0
--
-------------------------------------------------------------------------------
--
-- Description :				
-- Each 128-bit register is separated into 32-bit fields (formatted by HI and LO 16-bit subfields)
-- 1) Load immediate		 
-- 2) Multiply-add and multiply-subtract R4-Instruction Format
-- 3) R3-Instruction Format	
-- 5-bit long 'rs3, rs2, rs1, rd' named in the 'instruction' represents the register number out of the 32 registers
--
-------------------------------------------------------------------------------

--{{ Section below this comment is automatically maintained
--    and may be overwritten
--{entity {multimedia_alu_op_execute} architecture {behavioral}}

library IEEE; 
use IEEE.std_logic_1164.all;  
use IEEE.numeric_std.all;			  

entity multimedia_alu_op_execute is
	port(
		rd : out STD_LOGIC_VECTOR(127 downto 0) := (others => '0');
		rs1 : in STD_LOGIC_VECTOR(127 downto 0) := (others => '0');
		rs2 : in STD_LOGIC_VECTOR(127 downto 0) := (others => '0');
		rs3 : in STD_LOGIC_VECTOR(127 downto 0) := (others => '0');
		instruction : in STD_LOGIC_VECTOR(24 downto 0);
		alu_rd_addr : out STD_LOGIC_VECTOR(4 downto 0);
		clk : in STD_LOGIC;
		alu_to_write_back : out STD_LOGIC := '0';
		valid_data_ALU : OUT STD_LOGIC := '0'
	);
end multimedia_alu_op_execute;

--}} End of automatically maintained section

architecture behavioral of multimedia_alu_op_execute is
	signal alu_result : std_logic_vector(127 downto 0) := (others => '0');
    signal alu_to_write_back_reg : std_logic := '0';
begin
	alu : process(instruction, rs1, rs2, rs3, clk)
	variable lower16_rs3, lower16_rs2, lower16_rs1, lower16_rd : signed(15 downto 0);
	variable upper16_rs3, upper16_rs2, upper16_rs1, upper16_rd : signed(15 downto 0);
	variable lower32_rs3, lower32_rs2, lower32_rs1, lower32_rd : signed(31 downto 0);
	variable upper32_rs3, upper32_rs2, upper32_rs1, upper32_rd : signed(31 downto 0);
	variable product32, result32 : signed(32 downto 0);
	variable product32_unsigned : unsigned(31 downto 0);
	variable product64, result64 : signed(64 downto 0);
	variable halfword_rs1, halfword_rs2, halfword_rd : signed(16 downto 0);
	variable result16 : signed(16 downto 0);
	variable shift_amount : integer;
	variable halfword : std_logic_vector(15 downto 0);
	variable count : integer := 0;
	variable lower16_rs1_unsigned, lower16_rs2_unsigned : unsigned(15 downto 0);
	variable rotated_halfword : std_logic_vector(15 downto 0);	
	variable temp16 : signed(15 downto 0);
	variable temp32 : signed(31 downto 0);
	variable temp64 : signed(63 downto 0);
	constant MAX_64_SIGNED : signed(63 downto 0) := x"7FFFFFFFFFFFFFFF"; -- 2^63 - 1 = 9223372036854775807
	constant MIN_64_SIGNED : signed(63 downto 0) := x"8000000000000000"; -- -2^63 = -9223372036854775808
	variable result32_unsigned : unsigned(31 downto 0);
	constant MAX_16_SIGNED : signed(15 downto 0) := x"7FFF"; 
	constant MIN_16_SIGNED : signed(15 downto 0) := x"8000";
	begin	
		------------------------------------------------------------------
		-- 4.1 Load Immediate
		------------------------------------------------------------------

	-- Load Immediate Instruction:	
	-- a 16-bit immediate value loaded into one of the eight 16-bit of a 128-bit register, rd
	-- 'load index' 23:21 specifies which field of rd to place immediate value into
	-- can only load half-words at a time (16-bits)
	-- other halfword fields are preserved (NOT CLEARED to '0')	
	-- just make this check the 24th bit of the instruction for the load instruction
	if rising_edge(clk) then 
		if (instruction(24) = '0') then
		alu_to_write_back <= '1';
		case instruction(23 downto 21) is
			when "000" =>
				rd(15 downto 0) <= instruction(20 downto 5);
			when "001" =>
				rd(31 downto 16) <= instruction(20 downto 5);
			when "010" =>
				rd(47 downto 32) <= instruction(20 downto 5);
			when "011" =>
				rd(63 downto 48) <= instruction(20 downto 5);
			when "100" =>
				rd(79 downto 64) <= instruction(20 downto 5);
			when "101" =>
				rd(95 downto 80) <= instruction(20 downto 5);
			when "110" =>
				rd(111 downto 96) <= instruction(20 downto 5);
			when "111" =>
				rd(127 downto 112) <= instruction(20 downto 5);
			when others =>
				null;
		end case; 
		
		------------------------------------------------------------------
		-- 4.2 Multiply-Add and Multiply-Subtract R4-Instruction Format
		------------------------------------------------------------------

	elsif (instruction(24 downto 23) = "10") then 
		-- Multiply-Add and Multiply-Subtract R4 Instruction:
		-- R4 Instruction:
		-- saturated rounding = take result, and sets floor/ceiling corresponding to max range for that data size 
		-- instead of underflow/overflow wrapping, the max/min values are used
		case (instruction(22 downto 20)) is 
			when "000" =>
			-- Signed Integer Multiply-Add Low with Saturation: 
			-- Multiply low 16-bit-fields of each 32-bit field of registers rs3 and rs2
			for i in 0 to 3 loop
				product32 := resize((signed(rs3((i+1) * 32 - 17 downto i*32)) * signed(rs2((i+1) * 32 - 17 downto i*32))), 33);
				--then add 32-bit products to 32-bit fields of register rs1
				result32 := signed(rs1((i+1) * 32 - 1 downto i*32)) + product32;
				--saturation check
				if result32 > to_signed(2147483647, 33) then 
					temp32 := to_signed(2147483647, 32);
				elsif result32 < to_signed(-2147483648, 33) then 
					temp32 := to_signed(-2147483648, 32);
				else
					temp32 := resize(result32, 32);
				end if;
				-- and save result in register rd
				rd(((i+1) * 32) -1 downto i*32) <= std_logic_vector(temp32);
			end loop;
					 
			when "001" => 
			-- Signed Integer Multiply-Add High with Saturation:
			-- Multiply high 16-bit-fields of each 32-bit field of registers rs3 and rs2
			for i in 0 to 3 loop
				upper16_rs3 := signed(rs3((i+1) * 32 - 1 downto (i+1)*32 - 16));
				upper16_rs2 := signed(rs2((i+1) * 32 - 1 downto (i+1)*32 - 16));
				
				product32 := resize(upper16_rs3 * upper16_rs2, 33);
				--then add 32-bit products to 32-bit fields of register rs1
				result32 := signed(rs1((i+1) * 32 - 1 downto i*32)) + product32;
				
				--saturation check
				if result32 > to_signed(2**31 -1, 33) then 
					temp32 := to_signed(2**31 -1, 32);
				elsif result32 < to_signed(-2**31, 33) then 
					temp32 := to_signed(-2**31, 32);
				else
					temp32 := resize(result32, 32);
				end if;
				-- and save result in register rd
				rd((i+1) * 32 -1 downto i*32) <= std_logic_vector(temp32);
			end loop;

			when "010" =>
			--Signed Integer Multiply-Subtract Low with Saturation:
			--Multiply low 16-bit-fields of each 32-bit field of registers rs3 and rs2
			for i in 0 to 3 loop
				lower16_rs3 := signed(rs3((i+1) * 32 - 17 downto i*32));
				lower16_rs2 := signed(rs2((i+1) * 32 - 17 downto i*32));
				
				product32 := resize(lower16_rs3 * lower16_rs2, 33);
				--then subtract 32-bit products from 32-bit fields of register rs1, 
				result32 := signed(rs1((i+1) * 32 - 1 downto i*32)) - product32;
				
				--saturation check
				if result32 > to_signed(2**31 -1, 33) then 
					temp32 := to_signed(2**31 -1, 32);
				elsif result32 < to_signed(-2**31, 33) then 
					temp32 := to_signed(-2**31, 32);
				else
					temp32 := resize(result32, 32);
				end if;

				-- and save result in register rd
				rd((i+1) * 32 -1 downto i*32) <= std_logic_vector(temp32);
			end loop;
			
			when "011" =>
			--Signed Integer Multiply-Subtract High with Saturation: 
			--Multiply high 16-bit-fields of each 32-bit field of registers rs3 and rs2
			for i in 0 to 3 loop
				upper16_rs3 := signed(rs3((i+1) * 32 - 1 downto (i+1)*32 - 16));
				upper16_rs2 := signed(rs2((i+1) * 32 - 1 downto (i+1)*32 - 16));

				product32 := resize(upper16_rs3 * upper16_rs2, 33);
			--then subtract 32-bit products from32-bit fields of register rs1, 
				result32 := signed(rs1((i+1) * 32 - 1 downto i*32)) - product32;
				
				--saturation check
				if result32 > to_signed(2**31 -1, 33) then 
					temp32 := to_signed(2**31 -1, 32);
				elsif result32 < to_signed(-2**31, 33) then 
					temp32 := to_signed(-2**31, 32);
				else
					temp32 := resize(result32, 32);
				end if;
				-- and save result in register rd
				rd((i+1) * 32 -1 downto i*32) <= std_logic_vector(temp32);
			end loop;
			
			when "100" =>
			--Signed Long Integer Multiply-Add Low with Saturation: 
			-- Multiply low 32-bit-fields of each 64-bit field of registers rs3 and rs2
			for i in 0 to 1 loop
				lower32_rs3 := signed(rs3((i*64) + 31 downto i*64));
				lower32_rs2 := signed(rs2((i*64) + 31 downto i*64));
				
				product64 := resize(lower32_rs3 * lower32_rs2, 65);
				--then add 64-bit products to 64-bit fields of register rs1
				result64 := signed(rs1((i*64) + 63 downto i*64)) + product64;
				
			--saturation check
			if result64 > MAX_64_SIGNED then 
				temp64 := MAX_64_SIGNED;
			elsif result64 < MIN_64_SIGNED then 
				temp64 := MIN_64_SIGNED;
			else
				temp64 := resize(result64, 64);
			end if;
				-- and save result in register rd
				rd((i+1) * 64 -1 downto i*64) <= std_logic_vector(temp64);
			end loop;
			
			when "101" =>
			--Signed Long Integer Multiply-Add High with Saturation: 
			--Multiply high 32-bit- fields of each 64-bit field of registers rs3 and rs2, 
			for i in 0 to 1 loop
				upper32_rs3 := signed(rs3((i+1) * 64 - 1 downto (i+1)*64 - 32));
				upper32_rs2 := signed(rs2((i+1) * 64 - 1 downto (i+1)*64 - 32));
				
				product64 := resize(upper32_rs3 * upper32_rs2, 65);
				--then add 64-bit products to 64-bit fields of register rs1
				result64 := signed(rs1((i+1) * 64 - 1 downto i*64)) + product64;
				
			--saturation check
			if result64 > MAX_64_SIGNED then 
				temp64 := MAX_64_SIGNED;
			elsif result64 < MIN_64_SIGNED then 
				temp64 := MIN_64_SIGNED;
			else
				temp64 := resize(result64, 64);
			end if;
				-- and save result in register rd
				rd((i+1) * 64 -1 downto i*64) <= std_logic_vector(temp64);
			end loop;
	
			when "110" =>
			--Signed Long Integer Multiply-Subtract Low with Saturation: 
			--Multiply low 32- bit-fields of each 64-bit field of registers rs3 and rs2,
			for i in 0 to 1 loop
				lower32_rs3 := signed(rs3((i*64) + 31 downto i*64));
				lower32_rs2 := signed(rs2((i*64) + 31 downto i*64));
				
				product64 := resize(lower32_rs3 * lower32_rs2, 65);
				--then subtract 64-bit products from 64-bit fields of register rs1, 
				result64 := signed(rs1((i+1) * 64 - 1 downto i*64)) - product64;
				
				--saturation check
				if result64 > MAX_64_SIGNED then 
					temp64 := MAX_64_SIGNED;
				elsif result64 < MIN_64_SIGNED then 
					temp64 := MIN_64_SIGNED;
				else 
					temp64 := resize(result64, 64);
				end if;
				-- and save result in register rd
				rd((i+1) * 64 -1 downto i*64) <= std_logic_vector(temp64);
			end loop;
			
			when "111" =>
			--Signed Long Integer Multiply-Subtract High with Saturation:
			--Multiply high 32-bit-fields of each 64-bit field of registers rs3 and rs2,
			for i in 0 to 1 loop
				upper32_rs3 := signed(rs3((i*64) + 31 downto i*64));
				upper32_rs2 := signed(rs2((i*64) + 31 downto i*64));
				
				product64 := resize(upper32_rs3 * upper32_rs2, 65);
				--then subtract 64-bit products from 64-bit fields of register rs1, 
				result64 := signed(rs1((i+1) * 64 - 1 downto i*64)) - product64;
				
				--saturation check
				if result64 > MAX_64_SIGNED then 
					temp64 := MAX_64_SIGNED;
				elsif result64 < MIN_64_SIGNED then 
					temp64 := MIN_64_SIGNED;
				else 
					temp64 := resize(result64, 64);
				end if;
				-- and save result in register rd
				rd((i+1) * 64 -1 downto i*64) <= std_logic_vector(temp64);
			end loop;
			
			when others =>
				null;
		end case;			
		
		------------------------------------------------------------------
		-- 4.3 Multiply-Add and Multiply-Subtract R4-Instruction Format
		------------------------------------------------------------------
		
	elsif (instruction(24 downto 23) = "11") then
		-- R3 Instruction:
		-- 16-bit signed int add/subtract (AHS/SFHS) operation performed w/ saturation to signed halfword rounding
		-- takes 16-bit signed int X, and converts to -32768 if less than -32768
		-- takes 16-bit signed int X, and converts to +32767 if greater than 32767
		case std_logic_vector(instruction(18 downto 15)) is
			when "0000" =>
			-- no operation
			when "0001" =>
			--SLHI: shift left halfword immediate: 
			--packed 16-bit halfword shift left logical of the contents of register rs1 (namely, each of the 8 16-bit halfwords in rs1) by the value of the four least significant bits of instruction field rs2. 
			--Each of the 16-bit results is placed into the corresponding 16-bit slot in register rd. 
			--(Comments: 8 separate 16-bit values in each 128-bit register)
			shift_amount := to_integer(unsigned(instruction(14 downto 10)));
			for i in 0 to 7 loop
				rd((i+1) * 16 - 1 downto i*16) <= std_logic_vector(unsigned(rs1((i+1) * 16 - 1 downto i*16)) sll shift_amount);
			end loop;
			
			when "0010" =>
			--AU: add word unsigned: 
			--packed 32-bit unsigned addition of the contents of registers rs1 and rs2 
			--(Comments: 4 separate 32-bit values in each 128-bit register)
			for i in 0 to 3 loop
				rd((i+1) * 32 - 1 downto i*32) <= std_logic_vector(unsigned(rs1((i+1) * 32 - 1 downto i*32)) + unsigned(rs2((i+1) * 32 - 1 downto i*32)));
			end loop;
			
			when "0011" =>
			--CNT1H: count 1s in halfwords: 
			--count 1s in each packed 16-bit halfword of the contents of register rs1. 
			--The results are placed into corresponding halfword slots in register rd . 
			--(Comments: 8 separate 16-bit values in each 128-bit register)
			for i in 0 to 7 loop
				halfword := rs1((i+1) * 16 - 1 downto i*16);
				count := 0; -- Reset count for each halfword
				--count the number of 1s
				for j in 0 to 15 loop
					if halfword(j) = '1' then
						count := count + 1;
					end if;
				end loop;
				
				--store count in RD
				rd((i+1) * 16 - 1 downto i*16) <= std_logic_vector(to_unsigned(count, 16));
			end loop;

			when "0100" =>
			--AHS: add halfword saturated : 
			--packed 16-bit halfword signed addition with saturation of the contents of registers rs1 and rs2 . 
			--(Comments: 8 separate 16-bit values in each 128-bit register)
			for i in 0 to 7 loop
				halfword_rs1 := resize(signed(rs1((i+1) * 16 - 1 downto i*16)), 17);
				halfword_rs2 := resize(signed(rs2((i+1) * 16 - 1 downto i*16)), 17);

				result16 := resize(halfword_rs1 + halfword_rs2, 17);
				--saturation check
				if result16 > to_signed(32767, 17) then
					temp16 := to_signed(32767, 16);
				elsif result16 < to_signed(-32768, 17) then
					temp16 := to_signed(-32768, 16);
				else 
					temp16 := resize(result16, 16);
				end if;
				rd(((i+1) * 16) - 1 downto i*16) <= std_logic_vector(temp16);
			end loop; 
					
			when "0101" =>
			--AND: bitwise logical and of the contents of registers rs1 and rs2
			for i in 0 to 127 loop
				rd(i) <= rs1(i) and rs2(i);
			end loop;
			
			when "0110" =>
			--BCW: broadcast word : 
			--broadcast the rightmost 32-bit word of register rs1 to each of the four 32-bit words of register rd
			for i in 0 to 3 loop
				rd((i+1) * 32 - 1 downto i*32) <= rs1(31 downto 0);
			end loop;
			
			when "0111" =>
			-- MAXWS: max signed word: 
			--for each of the four 32-bit word slots, place the maximum signed value between rs1 and rs2 in register rd. 
			--(Comments: 4 separate 32-bit values in each128-bit register)
			for i in 0 to 3 loop 
				if signed(rs1((i+1) * 32 - 1 downto i*32)) > signed(rs2((i+1) * 32 - 1 downto i*32)) then
					rd((i+1) * 32 - 1 downto i*32) <= rs1((i+1) * 32 - 1 downto i*32);
				else
					rd((i+1) * 32 - 1 downto i*32) <= rs2((i+1) * 32 - 1 downto i*32);
				end if;
			end loop;
			
			when "1000" =>
			-- MINWS: min signed word: 
			--for each of the four 32-bit word slots, 
			--place the minimum  signed value between rs1 and rs2 in register rd . 
			--(Comments: 4 separate 32-bit values in each 128-bit register)
			for i in 0 to 3 loop
				if signed(rs1((i+1) * 32 - 1 downto i*32)) < signed(rs2((i+1) * 32 - 1 downto i*32)) then
					rd((i+1) * 32 - 1 downto i*32) <= rs1((i+1) * 32 - 1 downto i*32);
				else
					rd((i+1) * 32 - 1 downto i*32) <= rs2((i+1) * 32 - 1 downto i*32);
				end if;
			end loop;
			
			when "1001" => 
			--MLHU: multiply low unsigned: 
			--the 16 rightmost bits of each of the four 32-bit slots in register rs1 are multiplied by the 16 rightmost bits of the corresponding 32-bit slots in register rs2, treating both operands as unsigned. 
			--The four 32-bit products are placed into the corresponding slots of register rd . 
			--(Comments: 4 separate 32-bit values in each 128-bit register)
			for i in 0 to 3 loop
				lower16_rs1_unsigned := unsigned(rs1((i+1) * 32 - 17 downto i*32));
				lower16_rs2_unsigned := unsigned(rs2((i+1) * 32 - 17 downto i*32));
				
				product32_unsigned := lower16_rs1_unsigned * lower16_rs2_unsigned;
				rd((i+1) * 32 - 1 downto i*32) <= std_logic_vector(product32_unsigned);
			end loop;
			
			when "1010" =>
			--MLHCU: multiply low by constant unsigned: 
			--the 16 rightmost bits of each of the four 32-bit slots in register rs1 are multiplied by a 5-bit value in the rs2 field of the instruction, treating both operands as unsigned. 
			--The four 32-bit products are placed into the corresponding slots of register rd . 
			--(Comments: 4 separate 32-bit values in each 128-bit register)
			for i in 0 to 3 loop
				lower16_rs1_unsigned := unsigned(rs1((i+1) * 32 - 17 downto i*32));
				product32_unsigned := resize(lower16_rs1_unsigned * unsigned(instruction(14 downto 10)),32);
				rd((i+1) * 32 - 1 downto i*32) <= std_logic_vector(product32_unsigned);
			end loop;

			when "1011" =>
			--OR: bitwise logical or of the contents of registers rs1 and rs2
			for i in 0 to 127 loop
				rd(i) <= rs1(i) or rs2(i);
			end loop;
			
			when "1100" =>
			--CLZH: count leading zeroes in halfwords: 
			--for each of the eight 16-bit halfword slots in register rs1, 
			--count the number of zero bits to the left of the first “1”. 
			--If the halfword slot in register rs1 is zero, the result is 16.
			-- The eight results are placed into the corresponding 16-bit halfword slots in register rd. 
			--(Comments: 8 separate 16-bit values in each 128-bit register)
			for i in 0 to 7 loop
				halfword := rs1((i+1) * 16 - 1 downto i*16);
				count := 0; -- Reset count for each halfword
				for j in 15 downto 0 loop
					if halfword(j) = '0' then
						count := count + 1;
					else
						exit;
					end if;
				end loop;
				if halfword = "0000000000000000" then
					count := 16;
				end if;
				rd((i+1) * 16 - 1 downto i*16) <= std_logic_vector(to_unsigned(count, 16));
			end loop;

			when "1101" =>
			--RLH: rotate left bits in halfwords : 
			--the contents of each 16-bit field in register rs1 are  rotated to the left according to the value of the 4 least significant bits of the corresponding 16-bit field in register rs2. 
			--The results are placed in register rd.
			-- Bits rotated out of the left end of each word are rotated in on the right end of the same 16-bit word field. 
			--(Comments: 8 separate 16-bit halfword values in each 128-bit register)
			for i in 0 to 7 loop
				halfword := rs1((i+1) * 16 - 1 downto i*16);
				shift_amount := to_integer(unsigned(rs2((i+1) * 16 - 13 downto i*16)));
				
				rotated_halfword := halfword(15 - shift_amount downto 0) & halfword(15 downto 16 - shift_amount);

				rd((i+1) * 16 - 1 downto i*16) <= rotated_halfword;
				end loop;

			when "1110" =>
			--SFWU: subtract from word unsigned: 
			--packed 32-bit word unsigned subtract of the contentsof rs1 from rs2 (rd = rs2 - rs1). 
			--(Comments: 4 separate 32-bit values in each 128-bit register)
			for i in 0 to 3 loop
				rd((i+1) * 32 - 1 downto i*32) <= std_logic_vector(unsigned(rs2((i+1) * 32 - 1 downto i*32)) - unsigned(rs1((i+1) * 32 - 1 downto i*32)));
			end loop;
			when "1111" =>
				--SFHS: subtract from halfword saturated: 
				--packed 16-bit halfword signed subtraction with saturation of the contents of rs1 from rs2 (rd = rs2 - rs1). 
				--(Comments: 8 separate 16-bit values in each 128-bit register)
				for i in 0 to 7 loop
					halfword_rs1 := resize(signed(rs1((i+1) * 16 - 1 downto i*16)), 17);
					halfword_rs2 := resize(signed(rs2((i+1) * 16 - 1 downto i*16)), 17);
	
					result16 := resize(halfword_rs2 - halfword_rs1, 17);

					--saturation check
					if result16 > to_signed(32767, 17) then
						temp16 := to_signed(32767, 16);
					elsif result16 < to_signed(-32768, 17) then
						temp16 := to_signed(-32768, 16);
					else 
						temp16 := resize(result16, 16);
					end if;
					rd((i+1) * 16 - 1 downto i*16) <= std_logic_vector(temp16);
				end loop;

			when others =>
				null;
		end case;
		else 
			null;
	end if;
	alu_rd_addr <= instruction(4 downto 0);
	end if;
	end process alu;
	
end behavioral;