Library ieee;
use ieee.std_logic_1164.all;

entity Excution_Flow is
    port(
        Pc_Select_initial: in std_logic_vector(1 downto 0);
        Branch_Mode: in std_logic_vector(2 downto 0) ;
        Zero: in std_logic;
        Alu_LSB: in std_logic;
        Pc_Select_Final: out std_logic_vector(1 downto 0)
    );
end entity;

architecture arch of Excution_Flow is

Begin
    Process (Pc_Select_initial, Alu_LSB, Zero, Branch_Mode) Begin
        case Pc_Select_initial is
            when "00" => Pc_Select_Final<= "00";
            when "10" => Pc_Select_Final<= "10";
            when "11" => 
                case Branch_Mode is -- Branch Mode represnet if its Beq, Bne, Blt.......
                                    -- Branch Mode is basically pipelined Funct3
                    When "000"=> if (Zero='1') then
                        PC_select_Final<= "10";
                      else 
                        Pc_select_Final<= "01";
                      end if;
                    When "001"=> 
                        if(Zero='0') then 
                            Pc_select_Final<= "10";
                        else
                            Pc_select_Final<= "01";
                        end if;
                    When "100"=> 
                        if(Alu_LSB='1') then--Set less than 
                            Pc_select_Final<= "10";
                        else
                            Pc_select_Final<="01";
                        end if;
                    when "101"=> 
                        if(Alu_LSB='0') then 
                            Pc_select_Final<="10";
                        else
                            Pc_select_Final<="01";
                        end if;
                    when "110"=> 
                        if(Alu_LSB='1') then   --Set less than unsigned
                            Pc_select_Final<= "10";
                        else 
                            Pc_select_Final<= "01";
                        end if;
                    when "111"=> 
                        if(Alu_LSB='0') then 
                            Pc_select_Final<= "10";
                        else 
                            Pc_select_Final<= "01";
                        end if;
                    when others=> Pc_select_Final<= "01";
                end case;
            when others=> Pc_select_Final<= "01";
        end case;
    end process;
end arch ; -- arch