Library ieee;
use ieee.std_logic_1164.all;

entity First_stage is
	port(Mem_in: in std_logic_vector(31 downto 0);
		 M,S: in std_logic_vector(1 downto 0);
		 A2: out std_logic_vector(31 downto 0));
end entity;

architecture arch of First_stage is
	Signal A1_Byte: std_logic_vector(7 downto 0);
	Signal A1_half: std_logic_vector(15 downto 0);
Begin 
	Process(M, S, Mem_in) Begin 
		case M is
			when "00"=> A2<= (others=>'-');
			when "01"=> if(S(0)='0') then
							A2<= Mem_in(31 downto 16) & (15 downto 0=> '0');
						else 
							A2<= (31 downto 16 => '0') & Mem_in(15 downto 0);
						end if;
			when "10"=> case S is
							when "00"=> A2<= Mem_in(31 downto 8) & (7 downto 0=>'0');
							when "01"=> A2<= Mem_in(31 downto 16) & (15 downto 8 =>'0') & Mem_in(7 downto 0);
							when "10"=> A2<= Mem_in(31 downto 24) & (23 downto 16=>'0') & Mem_in(15 downto 0);
							when "11"=> A2<= (31 downto 24=> '0') & Mem_in(23 downto 0);
							when others=> A2<= (others=>'-');	
						end case;
			when others=> A2<= (others=>'Z');		
		end case;
	end process;
 end architecture; 
			