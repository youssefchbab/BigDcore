Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TWO_RAM is 
    generic(N: integer := 32);
    port(
        clk,Reset: in std_logic;
        WE: in std_logic;
        Pc : in std_logic_vector(N-1 downto 0);
        Instruction: out std_logic_vector(N-1 downto 0);
        DataAdr: in std_logic_vector(N-1 downto 0);
        WriteData: in std_logic_vector(N-1 downto 0);
        ReadData: out std_logic_vector(N-1 downto 0)
    );
end entity;

architecture arch of TWO_RAM is
    component RAM is
        generic(N: integer:= 32);
        port (
            clk, Reset: in std_logic;
            WE: in std_logic;
            WriteData: in std_logic_vector(N-1 downto 0) ;
            DataAdr: in std_logic_vector(N-1 downto 0) ;
            ReadData: out std_logic_vector(N-1 downto 0) 
        ) ;
    end component;
    component RAM_Inst is
        generic(N: integer:= 32);
        port (
            clk, Reset: in std_logic;
            WE: in std_logic;
            WriteData: in std_logic_vector(N-1 downto 0) ;
            PC: in std_logic_vector(N-1 downto 0) ;
            ReadData: out std_logic_vector(N-1 downto 0) 
        ) ;
    end component;
    --SIGNALS
Begin
    Instruction_Memory: RAM_Inst port map(clk, Reset, '0', (others => '0'), Pc, Instruction);
    Data_Memory: RAM port map(clk, Reset, WE, WriteData, DataAdr, ReadData);
end arch;