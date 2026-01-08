Library ieee;
use ieee.std_logic_1164.all;
use ieee.Numeric_std.all;
-- This Circuit job is to shift the address to right by 2
entity Address_Mod is
	port(Address_in: in std_logic_vector(31 downto 0);
		 Address_out: out std_logic_vector(31 downto 0));
end entity;

architecture arch of Address_Mod is
	Signal Address_outtemp: unsigned(31 downto 0);
Begin
	Address_outtemp<= shift_right(unsigned(Address_in), 2);
	Address_out<= std_logic_vector(Address_outtemp);
end architecture;