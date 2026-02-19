library ieee;
use ieee.std_logic_1164.all;

entity MemTest is
end entity;

architecture arch of MemTest is
    component Byte_Addr_Mem is
        generic(N: integer:= 32);
        port (
            clk, Reset: in std_logic;
            WE: in std_logic;
            Mode: in std_logic_vector(1 downto 0);--Byte/HalfWord/Word
            ALU_LSB: in std_logic_vector(1 downto 0);
            WriteData: in std_logic_vector(N-1 downto 0) ;
            DataAdr: in std_logic_vector(N-1 downto 0) ;
            ReadData: out std_logic_vector(N-1 downto 0) 
        ) ;
    end component;
    Signal clk, reset: std_logic;
    Signal WE: std_logic;
    Signal Mode, ALU_LSB: std_logic_vector(1 downto 0) ;
    Signal WriteData, DataAdr, ReadData: std_logic_vector(31 downto 0);
begin
    UUT: Byte_Addr_Mem port map (
        clk, Reset,
        WE,
        Mode, ALU_LSB,
        WriteData, DataAdr,
        ReadData
    );
    clk_Gen: process Begin--Rising edge at 20, 40, 60,.....
        clk<='1';
        wait for 10 ns;
        clk<='0';
        wait for 10 ns;
    end process;
    Simulation: process begin
        reset<= '1';
        wait for 40 ns;
        reset<= '0';
        DataAdr<= (31 downto 8 =>'0') & x"64";
        WriteData<= (others=>'1');
        ALU_LSB<="00";
        Mode<="10";
        WE<= '1';
        wait for 20 ns; -- Store First Byte 60 ns
        DataAdr<= (31 downto 8 =>'0') & x"68";
        WriteData<= (others=>'1');
        ALU_LSB<="00";
        Mode<="00";
        WE<= '1';
        wait for 20 ns; -- Store Second Byte 80 ns
        DataAdr<= (31 downto 8 =>'0') & x"68";
        WriteData<= (others=>'1');
        ALU_LSB<="01";
        Mode<="00";
        WE<= '1';
        wait for 20 ns; -- Store Third Byte 100 ns
        DataAdr<= (31 downto 8 =>'0') & x"68";
        WriteData<= (others=>'1');
        ALU_LSB<="10";
        Mode<="00";
        WE<= '1';
        wait for 20 ns; -- Store Fourth Byte 120 ns
        DataAdr<= (31 downto 8 =>'0') & x"68";
        WriteData<= (others=>'1');
        ALU_LSB<="11";
        Mode<="00";
        WE<= '1';
        wait for 20 ns; -- Store Second Half 140 ns
        DataAdr<= (31 downto 8 =>'0') & x"6C";
        WriteData<= (others=>'1');
        ALU_LSB<="11";
        Mode<="01";
        WE<= '1';
        wait for 20 ns; -- Store Second Half 160 ns
        DataAdr<= (31 downto 8 =>'0') & x"6C";
        WriteData<= (others=>'1');
        ALU_LSB<="00";
        Mode<="01";
        WE<= '1';
        wait;
    end process;


end architecture;
