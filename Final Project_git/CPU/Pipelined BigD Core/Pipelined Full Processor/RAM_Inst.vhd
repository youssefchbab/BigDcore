Library ieee;
use ieee.std_logic_1164.all;
use ieee.Numeric_std.all;
--This is an alternative RAM module for Intsuctions only.
entity RAM_Inst is
    generic(N: integer:= 32);
    port (
        clk, Reset: in std_logic;
        WE: in std_logic;
        WriteData: in std_logic_vector(N-1 downto 0) ;
        PC: in std_logic_vector(N-1 downto 0) ;
        ReadData: out std_logic_vector(N-1 downto 0) 
    ) ;
end RAM_Inst;

architecture arch of RAM_Inst is
    Type RAM_type is array (255 downto 0) of std_logic_vector(N-1 downto 0) ;
    Signal Mem: RAM_type := (
        0=> x"05800093",
        4=> x"00000033",
        8=> x"00000033",
        12=> x"00000033",
        16=> x"06400193",
        20=> x"00000033",
        24=> x"00000033",
        28=> x"00000033",
        32=> x"0011a023",
        36=> x"00000033",
        40=> x"00000033",
        44=> x"00000033",
        48=> x"0001a103",
        52=> x"00000033",
        56=> x"00000033",
        60=> x"00000033",
        64=> x"00008a67",
        68=> x"00000033",
        72=> x"00000033",
        76=> x"00000033",
        80=> x"00000033",
        84=> x"00400213",
        88=> x"00500293",
        others => (others => '0')
    );
Begin
    Process(clk, PC) Begin
        If( Rising_edge(clk) )then
            if( WE='1' )then
                Mem(to_integer(unsigned(PC)))<= WriteData;
            end if;
        end if;
        if (to_integer(unsigned(PC)) >= 0 and to_integer(unsigned(PC))<= 255) then
            ReadData<= Mem(to_integer(unsigned(PC)));
        else
            --Ignore out of range addresses
            ReadData <= (others => '0');
            report "Warning: Address out of range";
        end if;
    end process;
end arch ; -- arch