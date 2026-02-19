Library ieee;
use ieee.std_logic_1164.all;

entity Alu_cntr is
	port(op_code: in std_logic_vector(6 downto 0) ;
		funct3: in std_logic_vector(2 downto 0) ;
		funct7, imm30: in std_logic;
		Alu_cntr: out std_logic_vector(3 downto 0));
end entity;

architecture arch of Alu_cntr is
	Signal temp : std_logic_vector(11 downto 0) ;
Begin
	temp<= imm30 &funct7 & funct3 & op_code;
	with temp select
		Alu_cntr<=
		x"0" when "-----0000011" | "--000001-011" | "-----0100011" | "-0000011-011" | "-----110-011" | "-----1101111",--add 
		x"1" when "-10000110011",--sub
		x"2" when "--1110010011" | "--111110011",--and             Rewrite the don't cares covreing all required cases
		x"3" when "--1100010011" | "--1100110011",--or
		x"4" when "--1000010011" | "--1000110011",--xor
		x"5" when "--0100010011" | "--0100110011" | "-10-1100011",--set less than slt
		x"6" when "--0110010011" | "--0110110011" | "-11-1100011",--set less than unsigned sltu
		x"7" when "--0010010011" | "--0010110011",--shift logical left sll
		x"8" when "0-1010010011" | "-01010110011",--shift logical right srl
		x"9" when "1-1010010011" | "-11010110011",--shift arithmetic right sra
		"ZZZZ" when others;		
	
		
	
end arch ; --Alu_cntr