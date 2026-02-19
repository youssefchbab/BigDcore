Library ieee;
use ieee.std_logic_1164.all;

entity RegEn_5it is
    generic(N: integer := 5);
    port (
        clk,Reset: in std_logic;
        En, Flush: in std_logic;
        NoN: in std_logic_vector(N-1 downto 0) ;
        D: in std_logic_vector(N-1 downto 0) ;
        Q: out std_logic_vector(N-1 downto 0)

    ) ;
end RegEn_5it;

architecture arch of RegEn_5it is

begin
    Process (clk, En) Begin 
        if(En='0') then
            if( Rising_edge(clk) )then
                if( Reset='1' ) then
                    Q<=(others=>'0');
                elsif(Flush='1') then
                    Q<= NoN;
                else
                    Q<=D;
                end if;
            end if;
        end if;
    end process;
end arch ; -- arch