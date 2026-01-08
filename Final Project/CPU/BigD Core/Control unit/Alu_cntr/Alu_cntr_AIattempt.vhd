library ieee;
use ieee.std_logic_1164.all;

entity ALU_Control_Branch_Sltiu_Map is
    port (
        Opcode : in  std_logic_vector(6 downto 0);
        Funct3 : in  std_logic_vector(2 downto 0);
        Funct7 : in  std_logic_vector(6 downto 0);
        ALU_Op : out std_logic_vector(3 downto 0)
    );
end entity ALU_Control_Branch_Sltiu_Map;

architecture Behavioral of ALU_Control_Branch_Sltiu_Map is

    constant ALU_ADD  : std_logic_vector(3 downto 0) := X"0";
    constant ALU_SUB  : std_logic_vector(3 downto 0) := X"1";
    constant ALU_AND  : std_logic_vector(3 downto 0) := X"2";
    constant ALU_OR   : std_logic_vector(3 downto 0) := X"3";
    constant ALU_XOR  : std_logic_vector(3 downto 0) := X"4";
    constant ALU_SLT  : std_logic_vector(3 downto 0) := X"5";
    constant ALU_SLTU : std_logic_vector(3 downto 0) := X"6";
    constant ALU_SLL  : std_logic_vector(3 downto 0) := X"7";
    constant ALU_SRL  : std_logic_vector(3 downto 0) := X"8";
    constant ALU_SRA  : std_logic_vector(3 downto 0) := X"9";
    constant ALU_Z    : std_logic_vector(3 downto 0) := (others => 'Z');

    -- Reversed control signal: Funct7(5) & Funct3(2:0) & Opcode(6:0)
    signal Control_Signal : std_logic_vector(10 downto 0);

begin

    Control_Signal <= Funct7(5) & Funct3 & Opcode;

    with Control_Signal select
        ALU_Op <=
            ALU_ADD  when "00000110011" | "00000010011" | "00000000011" | "00010000011" | "00100000011" | "01000000011" | "01010000011" | "00000100011" | "00010100011" | "00100100011" | "00000010111" | "00001100111" | "00001101111",
            ALU_SUB  when "10000110011",
            ALU_AND  when "01110110011" | "01110010011",
            ALU_OR   when "01100110011" | "01100010011",
            ALU_XOR  when "01000110011",                      -- Removed sltiu pattern ("00110010011")
            ALU_SLT  when "00100110011" | "00100010011" | "01001100011",
            ALU_SLTU when "00110110011" | "01101100011" | "00110010011", -- Added sltiu pattern ("00110010011")
            ALU_SLL  when "00010110011" | "00010010011",
            ALU_SRL  when "01010110011" | "01010010011",
            ALU_SRA  when "11010110011" | "11010010011",
            ALU_Z    when others;

end architecture Behavioral;


