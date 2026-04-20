Library ieee;
use ieee.std_logic_1164.all;
use ieee.Numeric_std.all;
entity RAM is
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
end RAM;
    
architecture arch of RAM is
    Type RAM_type is array (255 downto 0) of std_logic_vector(31 downto 0) ;
    Signal Mem: RAM_type := (
        172=> x"00000003",
        173=> x"00000007",
        174=> x"00000002",
        175=> x"00000009",
        176=> x"00000001",
        others => (others=>'0')
    );
    Signal Mem_Size: integer := 256;
Begin
    Process(clk, WE, DataAdr, ByteEn, Mode, Reset, WriteData) 
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