----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:41:35 05/06/2015 
-- Design Name: 
-- Module Name:    decoder - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.op_codes.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity decoder is
	Port (
		clk				: in  STD_LOGIC;
		reset			: in  STD_LOGIC;
		sleep			: in  STD_LOGIC;
		interrupt		: in  STD_LOGIC;
		interrupt_ack	: out STD_LOGIC;
		instruction		: in  unsigned (17 downto 0);
		opcode			: out unsigned (5 downto 0);
		opA				: out unsigned (3 downto 0);
		opB				: out unsigned (7 downto 0);
		carry			: in  STD_LOGIC;
		zero			: in  STD_LOGIC;
		jump			: out STD_LOGIC;
		jmp_addr		: out unsigned (11 downto 0);
		reg_mux			: out std_logic				-- 0 = alu, 1 = i/o ports
		);
end decoder;

architecture Behavioral of decoder is
	
	signal reg_select_o : std_logic;

begin

	reg_mux <= '0';

	decompse : process (instruction, reset, zero, carry) begin
	
		opcode	<= instruction(17 downto 12);
		opA		<= instruction(11 downto 8);
		opB		<= instruction(7 downto 0);
		jmp_addr <= instruction(11 downto 0);
			
		if (reset = '1') then
			jump <= '0';
		else
			case instruction(17 downto 12) is
			when OP_JUMP_AAA => 
				jump <= '1';
			when OP_JUMP_Z_AAA | OP_JUMP_NZ_AAA =>
				jump <= zero xor instruction(14);	-- inst(14) == opCode(2): 0 -> Z; 1 -> NZ
			when OP_JUMP_C_AAA | OP_JUMP_NC_AAA =>
				jump <= carry xor instruction(14);	-- inst(14) == opCode(2): 0 -> C; 1 -> NC
			when others =>
				jump <= '0';
			end case;
		end if;
		
	end process decompse;

	placeholder : process (clk) begin
		if (rising_edge(clk)) then
			if (reset = '1') then 
				interrupt_ack <= '0';
			else
				interrupt_ack <= carry and zero;
			end if;
		end if;
	end process placeholder;

end Behavioral;

