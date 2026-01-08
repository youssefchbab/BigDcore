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
    Type RAM_type is array (512 downto 0) of std_logic_vector(N-1 downto 0) ;
    Signal Mem: RAM_type :=(
        0=> x"12345537",
        others => (others => '0')) ; --Testing purposes only 
Begin
    Process(clk) Begin
        If( Rising_edge(clk) )then
            if( WE='1' )then
                Mem(to_integer(unsigned(PC)))<= WriteData;
            end if;
        end if;
        if (to_integer(unsigned(PC)) >= 0 and to_integer(unsigned(PC))<= 511) then
            ReadData<= Mem(to_integer(unsigned(PC)));
        else
            --Ignore out of range addresses
            ReadData <= (others => '0');
            report "Warning: Address out of range";
        end if;
    end process;
end arch ; -- arch