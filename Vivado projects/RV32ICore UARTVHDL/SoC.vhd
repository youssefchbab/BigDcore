Library ieee;
use ieee.std_logic_1164.all;
entity SoC is
  port (
    clock, reset_IN: in std_logic;
    LEDTest: out std_logic_vector(1 downto 0);
    UARTX_out: out std_logic
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
            WriteData: out std_logic_vector(31 downto 0);
            UART_EN: out std_logic;
            TX_out: out std_logic_vector(7 downto 0)
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
    component UART_TX is
        generic (
            g_CLKS_PER_BIT : integer := 434
            );
        port (
            i_Clk       : in  std_logic;
            i_TX_DV     : in  std_logic;
            i_TX_Byte   : in  std_logic_vector(7 downto 0);
            o_TX_Active : out std_logic;
            o_TX_Serial : out std_logic;
            o_TX_Done   : out std_logic
            );
    end component;
    --Signal Declaration 
    Signal clk ,reset: std_logic;
    Signal TX_Active, TX_Done, UART_E: std_logic;
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
        WriteData,
        UART_E
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
    UART: UART_TX port map(
        clock,
        UART_E,
        WriteData(7 downto 0),
        TX_Active,
        UARTX_out,
        TX_Done
    );
    clk<= clock;
    reset<= reset_IN;
    LEDTest<= ReadData(1 downto 0);
end arch ; --Soc