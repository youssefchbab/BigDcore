Library ieee;
use ieee.std_logic_1164.all;
-- NOTE: Flipflops are assumed as Acive High clr and set 
entity P_Main_unit is
  port (
    Reset: in std_logic;
    Funct3: in std_logic_vector(2 downto 0);
    Opcode: in std_logic_vector(6 downto 0);
    ImmExt: out std_logic_vector(2 downto 0);
    Word_Half_Byte: out std_logic_vector(1 downto 0);
    RegWrite: out std_logic;
    MemWrite: out std_logic;
    Mem_Ext_cntr: out std_logic_vector(2 downto 0);
    Write_Back_cntr: out std_logic_vector(1 downto 0);
    Pc_clr: out std_logic;
    Pc_select: out std_logic_vector(1 downto 0);
    Alu_input: out std_logic;
    Branch_Mode: out std_logic_vector(2 downto 0);
    Alu_input_for_auipc_and_lui: out std_logic_vector(1 downto 0)
  ) ;    
end P_Main_unit;

architecture arch of P_Main_unit is
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
    Pc_clr<= Reset;
    --PC_select
    Branch_Mode<= Funct3;
    process (Opcode, Funct3, Alu_LSB, Zero) Begin 
        case Opcode is --"10" is Target address, "01" is PC+4, "00" Target address but for jalr (uses register) 
        when Jump_And_Link_Reg_instruction => PC_select <="00";
        when Jump_instructions => PC_select<= "10";
        when Branch_intstructions => PC_select<= "11";
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
    RegWrite <= '0' when (Opcode = Store_instructions or Opcode = Branch_intstructions or Opcode = Jump_instructions) else '1';
    --Write_Back_cntr
    With Opcode select 
        Write_Back_cntr<= "00" when Jump_instructions | Jump_And_Link_Reg_instruction,
        "01" when Load_Instructions,
        "--" when Store_instructions | Branch_intstructions,
        "10" when others;
end arch ; --P_Main_unit