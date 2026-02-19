Library ieee;
use ieee.std_logic_1164.all;

entity CPU_Testbench is
end CPU_Testbench;

architecture arch of CPU_Testbench is
    component Processor is
        port(
            clk,Reset: in std_logic;
            Instruction: in std_logic_vector(31 downto 0);
            ReadData: in std_logic_vector(31 downto 0);
            MemWrite: out std_logic;
            Pc: out std_logic_vector(31 downto 0);
            DataAdr: out std_logic_vector(31 downto 0);
            WriteData: out std_logic_vector(31 downto 0)
        );
    end component;
    component TWO_RAM is 
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
    end component;
    --Signal Declaration 
    Signal clk, Reset: std_logic := '0';
    Signal MemWrite: std_logic;
    Signal Instruction: std_logic_vector(31 downto 0) ;
    Signal Pc: std_logic_vector(31 downto 0) ;
    Signal DataAdr: std_logic_vector(31 downto 0) ;
    Signal WriteData: std_logic_vector(31 downto 0) ;
    Signal ReadData: std_logic_vector(31 downto 0) ;
    --Constants
    constant clk_period : time := 10 ns;
Begin
    UUT: Processor port map(
        clk, 
        Reset, 
        Instruction, 
        ReadData, 
        MemWrite, 
        Pc, 
        DataAdr, 
        WriteData
    );
    Mem: TWO_RAM port map(
        clk, 
        Reset, 
        MemWrite, 
        Pc, 
        Instruction,
        DataAdr,
        WriteData, 
        ReadData
    );
    clk_process : process
    begin
        loop
            clk<='0';
            wait for 10 ns;
            clk<='1';
            wait for 10 ns;
        end loop;
    end process;

    Stimulus: process
    Begin 
        --Reset the system
        Reset<= '1';
        wait for clk_period*2;
        Reset<= '0';
        -- Add test-Bench Scenario here
        
        wait;
        end process;
end; -- arch