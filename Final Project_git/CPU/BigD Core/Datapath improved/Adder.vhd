Library ieee;
use ieee.std_logic_1164.all;
use ieee.Numeric_std.all;

entity adder is
	generic(N: integer:= 32);
	port(a,b: in std_logic_vector(N-1 downto 0);
		 y: out std_logic_vector(N-1 downto 0));
end entity;

architecture arch of adder is
	Signal At,Bt,Yt: unsigned(N-1 downto 0);
Begin 
	At<= unsigned(a);
	Bt<= unsigned(b);
	Yt<= At + Bt;
	y<= std_logic_vector(Yt);
end architecture;