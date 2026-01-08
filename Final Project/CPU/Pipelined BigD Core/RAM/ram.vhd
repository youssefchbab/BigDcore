Library ieee;
use ieee.std_logic_1164.all;
use ieee.Numeric_std.all;
entity RAM is
    generic(N: integer:= 32);
    port (
        clk, Reset: in std_logic;
        WE: in std_logic;
        WriteData: in std_logic_vector(N-1 downto 0) ;
        DataAdr: in std_logic_vector(N-1 downto 0) ;
        ReadData: out std_logic_vector(N-1 downto 0) 
    ) ;
end RAM;

architecture arch of RAM is
    Type RAM_type is array (255 downto 0) of std_logic_vector(N-1 downto 0) ;
    Signal Mem: RAM_type := (
        25=> x"00000040",
        26=> x"00000022",
        27=> x"00000016",
        28=> x"0000005A",
        29=> x"00000004",
        others => (others=>'0')
    );
Begin
    Process(clk, WE, DataAdr) Begin
        If( Rising_edge(clk) )then
            if( WE='1' )then
                Mem(to_integer(unsigned(DataAdr)))<= WriteData;
            end if;
        end if;
        if (to_integer(unsigned(DataAdr)) >= 0 and to_integer(unsigned(DataAdr))<= 255) then
            ReadData<= Mem(to_integer(unsigned(DataAdr)));
        else
            --Ignore out of range addresses
            ReadData <= (others => '0');
            report "Warning: Address out of range";
        end if;
    end process;
end arch ; -- arch