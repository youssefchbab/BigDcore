Library ieee;
use ieee.std_logic_1164.all;
--	Immediate Extender takes the whole intruction and then extract the immediate from said intruction and extends the imediate
--		according to the inst type.
entity ImmExt is
	port(inst: in std_logic_vector(31 downto 0) ;
		 ImmCntr: in std_logic_vector(2 downto 0);
		 Imm_Extended: out std_logic_vector(31 downto 0));
end entity;

architecture arch of ImmExt is

Begin 
	process(ImmCntr, inst) Begin
		case ImmCntr is
			When "000" => Imm_Extended<= (31 downto 12 => inst(31)) & inst(31 downto 20);--I-type 'CORRECT'
			When "001" => Imm_Extended<= (31 downto 13 => inst(31)) & inst(31 downto 24) & inst(11 downto 7);--S-type 'CORRECT'
			When "010" => Imm_Extended<= inst(31 downto 12) & (11 downto 0=>'0');        --U-type 'CORRECT'
			When "011" => Imm_Extended<= (31 downto 20=> inst(31)) & inst(19 downto 12) & inst(20) & inst(30 downto 21) & '0';--J-type 'CORRECT'
			When "100" => Imm_Extended<= (31 downto 12=> inst(31)) & inst(7) & inst(30 downto 25)& inst(11 downto 8) & '0';--B-type 'CORRECT'
			when "101" => Imm_Extended<=  (31 downto 5 => '0') & inst(24 downto 20);     --I-type shifts
			When others=> Imm_Extended<= (Others=>'Z'); 
		end case;
	end process;
end architecture;