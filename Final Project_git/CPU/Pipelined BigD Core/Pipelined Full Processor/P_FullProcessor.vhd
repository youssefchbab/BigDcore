Library ieee;
use ieee.std_logic_1164.all;
--This processor includes the whole processor with RAMs included

entity P_FullProcessor is
  port (
        clk,Reset: in std_logic
    ) ;
  
end P_FullProcessor;

architecture arch of P_FullProcessor is
    component Pipelined is
        port(
            clk,Reset: in std_logic;
            Instruction: in std_logic_vector(31 downto 0) ;
            ReadData: in std_logic_vector(31 downto 0) ;
            MemWrite: out std_logic;
            Pc: out std_logic_vector(31 downto 0) ;
            DataAdr: out std_logic_vector(31 downto 0) ;
            WriteData: out std_logic_vector(31 downto 0)
        );
    end component; 

    component RAM is
		  generic(N: integer := 32);
        port(
            clk, Reset: in std_logic;
            WE: in std_logic;
            WriteData: in std_logic_vector(N-1 downto 0) ;
            DataAdr: in std_logic_vector(N-1 downto 0) ;
            ReadData: out std_logic_vector(N-1 downto 0) 
        );
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
    --Signal Declaration 
    Signal MemWrite: std_logic;
    Signal Instruction: std_logic_vector(31 downto 0) ;
    Signal Pc: std_logic_vector(31 downto 0) ;
    Signal DataAdr: std_logic_vector(31 downto 0) ;
    Signal WriteData: std_logic_vector(31 downto 0) ;
    Signal ReadData: std_logic_vector(31 downto 0) ;
Begin
    CPU: Pipelined port map(
        clk, Reset,
        Instruction,
        ReadData,
        MemWrite,
        Pc,
        DataAdr,
        WriteData);
    Data_Memory: RAM port map(
        clk, Reset,
        MemWrite,
        WriteData,
        DataAdr,
        ReadData);
    Instruction_Memory: RAM_Inst port map(
        clk, Reset,
        '0',
        (others=>'0'),
        Pc,
        instruction
    );
end arch ; -- arch