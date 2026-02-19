Library ieee;
use ieee.std_logic_1164.all;

entity Reg_9bit is
    generic(N: integer := 9);
    port (
        clk,Reset: in std_logic;
        D: in std_logic_vector(N-1 downto 0) ;
        Q: out std_logic_vector(N-1 downto 0)

    ) ;
end Reg_9bit;

architecture arch of Reg_9bit is

begin
    Process (clk) Begin 
        if( Rising_edge(clk) )then
            if( Reset='1' ) then
                Q<=(others=>'0');
            else
                Q<=D;
            end if;
        end if;
    end process;
end arch ; -- arch