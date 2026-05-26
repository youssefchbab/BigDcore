Library ieee;
use ieee.std_logic_1164.all;

entity RegEn is
    generic(N: integer := 32);
    port (
        clk,Reset: in std_logic;
        stall, Flush: in std_logic;
        En: in std_logic;
        NoN: in std_logic_vector(N-1 downto 0) ;
        D: in std_logic_vector(N-1 downto 0) ;
        Q: out std_logic_vector(N-1 downto 0)

    ) ;
end RegEn;

architecture arch of RegEn is
	Signal Qtemp: std_logic_vector(N-1 downto 0);
begin
    Process (clk, En) Begin 
        if(En='0') then
            if( Rising_edge(clk) )then
                if( Reset='1' ) then
                    Qtemp<=(others=>'0');
                elsif(Flush='1') then
                    Qtemp<= NoN;
                elsif(stall='1') then 
                    Qtemp<=Qtemp;
                else
                    Qtemp<=D;
                end if;
            end if;
        end if;
    end process;
    Q<= Qtemp;
end arch ; -- arch