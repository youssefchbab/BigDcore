Library ieee;
use ieee.std_logic_1164.all;
entity SoC is
  port (
    clock, reset_IN: in std_logic;
    LEDTest: out std_logic_vector(1 downto 0)
  ) ;
end SoC;

architecture arch of Soc is
    --Component Declaration
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

    --Signal Declaration 
    Signal clk ,reset: std_logic;
    Signal LEDTest_Temp: std_logic_vector(1 downto 0);
    Signal instruction, ReadData: std_logic_vector(31 downto 0);
    Signal MemWrite: std_logic;
    Signal ByteEn, Mode: std_logic_vector(1 downto 0);
    Signal Pc: std_logic_vector(31 downto 0);
    Signal DataAdr, WriteData: std_logic_vector(31 downto 0);
begin
    CPU: P_Processor_Hazard port map(
        clk ,reset,
        instruction,
        ReadData,
        MemWrite,
        ByteEn, Mode,
        Pc,
        DataAdr,
        WriteData
    );
    --Instruction Memory
    Inst_RAM: RAM_Inst port map(
        clk, '0',
        '0',"00","00",
        (others=>'0'),
        Pc,
        instruction
    );
    --Data Memory 
    Data_RAM: RAM port map(
        clk, '0',
        MemWrite,
        Mode, ByteEn, 
        WriteData,
        DataAdr,
        ReadData
    );
    process(clk) begin
        if (rising_edge(clk)) then
            LEDTest_Temp<= WriteData(1 downto 0);
        else
            LEDTest_Temp<= LEDTest_Temp;
        end if;
    end process;
    clk<= clock;
    reset<= reset_IN;
    LEDTest<= LEDTest_Temp;
end arch ; --Soc