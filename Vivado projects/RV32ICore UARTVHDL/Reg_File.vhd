Library ieee;
Use ieee.std_logic_1164.all;
use ieee.Numeric_std.all;

entity Reg_File is
	port (a1,a2,a3: in std_logic_vector(4 downto 0);
		  clk,reset,we: in std_logic;
		  W: in std_logic_vector(31 downto 0);
		  R1,R2: out std_logic_vector(31 downto 0));
end entity;

architecture arch of Reg_File is
	--Declaring an array of registers
	Type regf is array (31 downto 0) of std_logic_vector(31 downto 0);
	Signal M:  regf;
Begin 
	process(clk,reset) Begin
		if (reset='1') then 
			M<= (others=>(others=>'0'));
		elsif(Rising_edge(clk))then 
			if (we='1' and a3/= "00000") then
					M(to_integer(unsigned(a3)))<= W;
			end if;
		end if;
	end process;
	--Hard wiring x0
	process(a1,a2,M,we,a3,W) begin
		if(a1="00000")then 
			R1<=(others=>'0');
		elsif (a1=a3) then
			R1<=W;
		else
			R1<= M(to_integer(unsigned(a1)));
		end if;
		if(a2="00000")then
			R2<=(others=>'0');
		elsif (a2=a3) then
			R2<= W;
		else
			R2<= M(to_integer(unsigned(a2)));
		end if;
	end process;
end;