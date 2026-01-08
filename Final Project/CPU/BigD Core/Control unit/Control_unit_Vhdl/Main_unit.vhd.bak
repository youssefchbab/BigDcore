Library ieee;
use ieee.std_logic_1164.all;
-- NOTE: Flipflops are assumed as Acive High clr and set 
entity Main_unit_with_smallBalls is
  port (
    Zero : in std_logic;
    Alu_LSB: in std_logic; --added input for Conditionals
    Funct3: in std_logic_vector(2 downto 0);
    Opcode: in std_logic_vector(6 downto 0);
    ImmExt: out std_logic_vector(2 downto 0);--Done
    Word_Half_Byte: out std_logic_vector(1 downto 0);--Done
    RegWrite: out std_logic;--Done
    MemWrite: out std_logic;--Done
    Mem_Ext_cntr: out std_logic_vector(2 downto 0);--Done
    Write_Back_cntr: out std_logic_vector(1 downto 0);--Done
    Pc_clr: out std_logic;--Done
    Pc_select: out std_logic_vector(1 downto 0);--Done
    Alu_input: out std_logic;--Done
    Alu_input_for_auipc_and_lui: out std_logic_vector(1 downto 0)--Done
  ) ;    
end Main_unit_with_smallBalls;

architecture arch of Main_unit_with_smallBalls is
  --The Following constants Represent the Opcodes for each 'type'
  constant R_type_instruction: std_logic_vector (6 downto 0) := "0110011";
  constant I_type_instruction_arih: std_logic_vector(6 downto 0) := "0010011";
  constant Store_instructions: std_logic_vector(6 downto 0) := "0100011";
  constant Branch_intstructions: std_logic_vector(6 downto 0) := "1100011";
  constant Jump_instructions: std_logic_vector(6 downto 0) := "1101111";
  constant Jump_And_Link_Reg_instruction: std_logic_vector(6 downto 0) :="1100111";
  constant Load_upper_immediate: std_logic_vector(6 downto 0) := "0110111";
  constant Add_Upper_immediate_to_PC: std_logic_vector(6 downto 0) := "0010111";
  constant Load_Instructions: std_logic_vector(6 downto 0) := "0000011";
Begin
  --ImmExt (Immediate extension)
  process (Opcode, Funct3) Begin 
    case Opcode is 
      when I_type_instruction_arih =>
        if (Funct3="001" or Funct3="101") then
          ImmExt<= "101";
        else
          ImmExt<= "000";
        end if ;
      when Load_Instructions => ImmExt<= "000";
      when Jump_And_Link_Reg_instruction => ImmExt<= "000";
      when Store_instructions => ImmExt <= "001";
      when Add_Upper_immediate_to_PC => ImmExt <= "010";
      when Load_upper_immediate => ImmExt <= "010";
      when Jump_instructions => ImmExt <= "011";
      when Branch_intstructions => ImmExt <= "100";
      when others => ImmExt <= "---";
    end case;
  end process;
  --Word_Half_Byte (Decides The size of data to be Stored into memory)
  Process (Opcode, Funct3) Begin 
    if (Opcode = Store_instructions) then
      case Funct3 is
        when "000"=> Word_Half_Byte <= "10";
        when "001"=> Word_Half_Byte <= "01";
        when "010"=> Word_Half_Byte <= "00";
        when others => Word_Half_Byte<= "--";
      end case;
    else 
      Word_Half_Byte<= "00";
    end if;
  end Process;
  --MemWrite 
  MemWrite<= '1' when (Opcode= Store_instructions) else '0';
  --Mem_Ext_cntr 
  Mem_Ext_cntr<= Funct3;
  --Pc_clr(Resets the Program counter to Zero)
  Pc_clr<='0';
  --PC_select
  process (Opcode, Funct3, Alu_LSB, Zero) Begin 
    case Opcode is --"10" is Target address, "01" is PC+4, "00" Target address but for jalr (uses register) 
      when Jump_And_Link_Reg_instruction => PC_select <="00";
      when Jump_instructions => PC_select<= "10";
      when Branch_intstructions => 
        case Funct3 is 
          When "000"=> if (Zero='1') then
                        PC_select<= "10";
                      else 
                        Pc_select<= "01";
                      end if;
          When "001"=> if(Zero='0') then 
                        Pc_select<= "10";
                      else
                        Pc_select<= "01";
                      end if;
          When "100"=> if(Alu_LSB='1') then--Set less than 
                        Pc_select<= "10";
                      else
                        Pc_select<="01";
                      end if;
          when "101"=> if(Alu_LSB='0') then 
                        Pc_select<="10";
                      else
                        Pc_select<="01";
                      end if;
          when "110"=> if(Alu_LSB='1') then   --Set less than unsigned
                        Pc_select<= "10";
                      else 
                        Pc_select<= "01";
                      end if;
          when "111"=> if(Alu_LSB='0') then 
                        Pc_select<= "10";
                      else 
                        Pc_select<= "01";
                      end if;
          when others=> Pc_select<= "01";
        end case;
      when others=> Pc_select<= "01";
    end case; 
  end process;
  -- Alu_input --Don't forget to Modify the Alu control unit or rewrite it--
  Alu_input <= '1' when (Opcode = R_type_instruction or Opcode = Branch_intstructions) else '0';
  --Alu_input_for_auipc_and_lui
  With Opcode select 
    Alu_input_for_auipc_and_lui<= 
      "10" when Load_upper_immediate,
      "01" when Add_Upper_immediate_to_PC,
      "00" when others;
  --RegWrite
  RegWrite <= '0' when (Opcode = Store_instructions or Opcode = Branch_intstructions) else '1';
  --Write_Back_cntr
  With Opcode select 
    Write_Back_cntr<= "00" when Jump_instructions | Jump_And_Link_Reg_instruction,
      "01" when Load_Instructions,
      "--" when Store_instructions | Branch_intstructions,
      "10" when others;
end arch ; --Main_unit_with_smallBalls