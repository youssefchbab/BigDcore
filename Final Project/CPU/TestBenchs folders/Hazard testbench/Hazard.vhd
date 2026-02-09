Library ieee;
use ieee.std_logic_1164.all;
entity Hazard_Testbench is
end entity;

architecture arch of Hazard_Testbench is
    component P_Processor_Hazard is
        port (
            clk, reset: in std_logic;
            instruction: in std_logic_vector (31 downto 0);
            ReadData: in std_logic_vector (31 downto 0);
            MemWrite: out std_logic;
            ByteEn, Mode: out std_logic_vector(1 downto 0);
            Pc: out std_logic_vector(31 downto 0) ;
            DataAdr: out std_logic_vector(31 downto 0) ;
            WriteData: out std_logic_vector(31 downto 0)
  ) ;
    end component;
    component RAM_Inst is
        generic(N: integer:= 32);
        port (
        clk, Reset: in std_logic;
        WE: in std_logic;
        Mode: in std_logic_vector(1 downto 0);--Byte/HalfWord/Word
        ByteEn: in std_logic_vector(1 downto 0);--Which Byte/Half
        WriteData: in std_logic_vector(N-1 downto 0) ;
        DataAdr: in std_logic_vector(N-1 downto 0) ;
        ReadData: out std_logic_vector(N-1 downto 0) 
    ) ;
    end component;
    component RAM is
        generic(N: integer:= 32);
        port (
        clk, Reset: in std_logic;
        WE: in std_logic;
        Mode: in std_logic_vector(1 downto 0);--Byte/HalfWord/Word
        ByteEn: in std_logic_vector(1 downto 0);--Which Byte/Half
        WriteData: in std_logic_vector(N-1 downto 0) ;
        DataAdr: in std_logic_vector(N-1 downto 0) ;
        ReadData: out std_logic_vector(N-1 downto 0) 
    ) ;
    end component;
    Signal clk ,reset: std_logic;
    Signal instruction, ReadData: std_logic_vector(31 downto 0);
    Signal MemWrite: std_logic;
    Signal ByteEn, Mode: std_logic_vector(1 downto 0);
    Signal Pc: std_logic_vector(31 downto 0);
    Signal DataAdr, WriteData: std_logic_vector(31 downto 0);
    Signal clk_cnt, Inst_Change_Cnt: integer := 0;--number Of clocks counter
begin
    UUT: P_Processor_Hazard port map(
        clk ,reset,
        instruction,
        ReadData,
        MemWrite,
        ByteEn, Mode,
        Pc,
        DataAdr,
        WriteData
    );
    Data_RAM: RAM port map(
        clk, '0',
        MemWrite,
        Mode, ByteEn, 
        WriteData,
        DataAdr,
        ReadData
    );
    Inst_RAM: RAM_Inst port map(
        clk, '0',
        '0',"00","00",
        (others=>'0'),
        Pc,
        instruction
    );
    clock: process Begin
        loop
            clk<= '1';
            wait for 10 ns;
            clk<= '0';
            wait for 10 ns;
        end loop;
    end process;

    Clock_counter: process(clk) 
        variable last: std_logic_vector(31 downto 0);
    Begin
        if(rising_edge(clk)) then
            clk_cnt<= clk_cnt + 1;
            if (instruction /= last) then
                Inst_Change_Cnt <= Inst_Change_Cnt + 1;
            end if;
            last := instruction;
        end if;
    end process;

    Stimulus: process Begin
        reset<= '1';
        wait for 40 ns;
        reset<= '0';
        wait;
    end process;
end architecture;