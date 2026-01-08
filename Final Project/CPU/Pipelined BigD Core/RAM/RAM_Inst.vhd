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
        0 => x"06400293",
        4 => x"00028293",
        8 => x"06400313",
        12 => x"01030313",
        16 => x"00032303",
        20 => x"00000393",
        24 => x"04638663",
        28 => x"00000e13",
        32 => x"00000e93",
        36 => x"40730f33",
        40 => x"ffff0f13",
        44 => x"03ee0663",
        48 => x"002e1f93",
        52 => x"01f284b3",
        56 => x"0004a903",
        60 => x"0044a983",
        64 => x"0129d863",
        68 => x"0134a023",
        72 => x"0124a223",
        76 => x"00100e93",
        80 => x"001e0e13",
        84 => x"fd9ff06f",
        88 => x"000e8663",
        92 => x"00138393",
        96 => x"fb9ff06f",
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