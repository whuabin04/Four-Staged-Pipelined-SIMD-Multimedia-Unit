    -------------------------------------------------------------------------------
--
-- Title       : forwarding_unit
-- Design      : pipedlined_simd_multimedia_unit
-- Author      : Huabin Wu
-- Company     : Stony Brook University
--
-------------------------------------------------------------------------------
--
-- File        : C:/My_Designs/pipelined_simd_multimedia_unit/pipedlined_simd_multimedia_unit/src/forwarding_unit.vhd
-- Generated   : Fri Nov 29 20:06:37 2024
-- From        : Interface description file
-- By          : ItfToHdl ver. 1.0
--
-------------------------------------------------------------------------------
--
-- Description : Every instruction must use the most recent value of a register, 
-- even if this value has not yet been written to the Register File. Be mindful of 
-- the ordering of instructions; the most recent value should be used, in the event 
-- of two consecutive writes to a register, followed by a read from that same 
-- register. Your processor should never stall in the event of hazards.

-- Take extra care of which instructions require forwarding, and which ones do 
-- not. Namely, NOP and the instructions with Immediate fields do not contain one/two 
-- register sources. Only valid data and source/destination registers should be 
-- considered for forwarding. 
--
-------------------------------------------------------------------------------

--{{ Section below this comment is automatically maintained
--    and may be overwritten
--{entity {forwarding_unit} architecture {behavioral}}

library IEEE;
use IEEE.std_logic_1164.all;   
use IEEE.numeric_std.all;

entity forwarding_unit is
    port(
        mux1_out : out STD_LOGIC_VECTOR(127 downto 0); -- Forwarded value for r1
        mux2_out : out STD_LOGIC_VECTOR(127 downto 0); -- Forwarded value for r2
        mux3_out : out STD_LOGIC_VECTOR(127 downto 0); -- Forwarded value for r3
        r1 : in STD_LOGIC_VECTOR(127 downto 0);        -- Full data of r1
        r2 : in STD_LOGIC_VECTOR(127 downto 0);        -- Full data of r2
        r3 : in STD_LOGIC_VECTOR(127 downto 0);        -- Full data of r3
        r1_addr : in STD_LOGIC_VECTOR(4 downto 0);     -- Address of r1
        r2_addr : in STD_LOGIC_VECTOR(4 downto 0);     -- Address of r2
        r3_addr : in STD_LOGIC_VECTOR(4 downto 0);     -- Address of r3
        fwrd_rd_addr : in STD_LOGIC_VECTOR(4 downto 0);     -- Address of destination register (rd)
        rd_data : in STD_LOGIC_VECTOR(127 downto 0);   -- Data to be forwarded from rd
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        valid_data : in STD_LOGIC;
        yes_forwarding : out STD_LOGIC
    );
end forwarding_unit;

architecture behavioral of forwarding_unit is
    signal mux1_sel : std_logic := '0'; -- Initialize to 0
    signal mux2_sel : std_logic := '0'; -- Initialize to 0
    signal mux3_sel : std_logic := '0'; -- Initialize to 0
begin
    -- Forwarding control logic
    process(clk, reset)
    begin
        if reset = '1' then
            mux1_out <= (others => '0');
            mux2_out <= (others => '0');
            mux3_out <= (others => '0');
        elsif rising_edge(clk) then 
            if valid_data = '1' then
                -- Compare the destination register address (rd_addr) with source registers
                if fwrd_rd_addr = r1_addr  then
                    mux1_sel <= '1'; -- Forward to r1
                    mux1_out <= rd_data;
                    yes_forwarding <= '1';
                else
                    mux1_sel <= '0';
                    mux1_out <= r1;	
					yes_forwarding <= '0';
                end if;

                if fwrd_rd_addr = r2_addr then
                    mux2_sel <= '1'; -- Forward to r2
                    mux2_out <= rd_data;
                    yes_forwarding <= '1';
                else
                    mux2_sel <= '0';
                    mux2_out <= r2;	 
					yes_forwarding <= '0';
                end if;

                if fwrd_rd_addr = r3_addr then
                    mux3_sel <= '1'; -- Forward to r3
                    mux3_out <= rd_data;
                    yes_forwarding <= '1';
                else
                    mux3_sel <= '0';
                    mux3_out <= r3;	
					yes_forwarding <= '0';
                end if;    
            end if;  
        end if;
    end process;
    
end behavioral;