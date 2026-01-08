Library ieee;
use ieee.std_logic_1164.all;

entity Mux4 is
	generic(N: integer:= 32);
	port(a,b,c,d: in std_logic_vector(N-1 downto 0);
		 sel: in std_logic_vector(1 downto 0);
		 y: out std_logic_vector(N-1 downto 0));
end entity; 

architecture arch of Mux4 is
	
Begin 		 
	with sel select 
		y<= a when "00",
			b when "01",
			c when "10",
			d when "11",
			(others=>'0') when others;
end;