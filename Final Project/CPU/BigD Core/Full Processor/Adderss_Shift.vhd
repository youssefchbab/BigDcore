Library ieee;
use ieee.std_logic_1164.all;
use ieee.Numeric_std.all;
-- This Circuit job is to shift the address to right by 2
entity Adderss_Shift is
	port(Address_in: in std_logic_vector(31 downto 0);
		 Address_out: out std_logic_vector(31 downto 0));
end entity;

architecture arch of Adderss_Shift is
	Signal Address_outtemp: std_logic_vector(31 downto 0);
Begin
	Address_outtemp<= "00" & Address_in(31 downto 2);
	Address_out<= Address_outtemp;
end architecture;