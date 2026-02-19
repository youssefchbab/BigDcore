Library ieee;
use ieee.std_logic_1164.all;
use ieee.Numeric_std.all;
entity RAM_Inst is
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
end RAM_Inst;
    
architecture arch of RAM_Inst is
    Type RAM_type is array (255 downto 0) of std_logic_vector(31 downto 0) ;
    Signal Mem: RAM_type := (
        0 => x"06400293",
        1 => x"00028293",
        2 => x"06400313",
        3 => x"01030313",
        4 => x"00032303",
        5 => x"00000393",
        6 => x"04638663",
        7 => x"00000e13",
        8 => x"00000e93",
        9 => x"40730f33",
        10 => x"ffff0f13",
        11 => x"03ee0663",
        12 => x"002e1f93",
        13 => x"01f284b3",
        14 => x"0004a903",
        15 => x"0044a983",
        16 => x"0129d863",
        17 => x"0134a023",
        18 => x"0124a223",
        19 => x"00100e93",
        20 => x"001e0e13",
        21 => x"fd9ff06f",
        22 => x"000e8663",
        23 => x"00138393",
        24 => x"fb9ff06f",
        others => (others=>'0')
    );
    Signal Mem_Size: integer := 256;
Begin
    Process(clk, WE, DataAdr, ByteEn, Mode, Reset) 
        variable Address, Addresstemp: integer;
    Begin
        Addresstemp:= to_integer(unsigned(DataAdr));
        Address:= Addresstemp/4;
        if (Reset ='1') then 
            Mem<= (others => (others=>'0')) ;--Reset Logic
        elsIf( Rising_edge(clk) )then--Writing in Mem 
            if( WE='1' )then
                case Mode is 
                    when "00" =>
                        
                            if ByteEn="00" then
                                Mem(Address)<= Mem(Address)(31 downto 8) & WriteData(7 downto 0);
                            end if;
                            if ByteEn="01" then
                                Mem(Address) <= Mem(Address)(31 downto 16) & WriteData(15 downto 8) & Mem(Address)(7 downto 0);
                            end if;
                            if ByteEn="10" then
                                Mem(Address) <= Mem(Address)(31 downto 24) & WriteData(23 downto 16) & Mem(Address)(15 downto 0);
                            end if;
                            if ByteEn="11" then
                                Mem(Address) <= WriteData(31 downto 24) & Mem(Address)(23 downto 0);
                            end if;
        
                    when "01" =>
                        if(ByteEn(1)='0') then
                            Mem(Address) <= Mem(Address)(31 downto 16) & WriteData(15 downto 0);
                        else
                            Mem(Address) <= WriteData(31 downto 16) & Mem(Address)(15 downto 0);
                        end if; 
                    when "10" =>
                        Mem(Address) <= WriteData;
                    when others => Mem(Address) <= (others => '0');
                end case;
            end if;
        end if;
        
        if (Address >= 0 and Address<= Mem_Size-1) then--Reading from Mem
            ReadData<= Mem(Address);
        else
            --Ignore out of range Addresses
            ReadData <= (others => '0');
            report "Warning: Address out of range";
        end if;
    end process;
end arch ; -- arch