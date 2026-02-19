library ieee;
use ieee.std_logic_1164.all;

entity ALU_Control_Unit is
    port (
        Opcode_i : in  std_logic_vector(6 downto 0);
        Funct3_i : in  std_logic_vector(2 downto 0);
        Funct7_i : in  std_logic_vector(6 downto 0); -- Primarily Funct7_i(5) (Instruction[30]) is used
        ALUOp_o  : out std_logic_vector(3 downto 0)  -- Output to control the ALU
    );
end entity ALU_Control_Unit;

architecture Behavioral of ALU_Control_Unit is

    -- RISC-V Opcodes (relevant for ALU operation determination)
    constant OPCODE_LOAD         : std_logic_vector(6 downto 0) := "0000011"; -- For address calculation
    constant OPCODE_STORE        : std_logic_vector(6 downto 0) := "0100011"; -- For address calculation
    constant OPCODE_BRANCH       : std_logic_vector(6 downto 0) := "1100011"; -- For comparison
    constant OPCODE_ITYPE_ARITH  : std_logic_vector(6 downto 0) := "0010011"; -- ADDI, SLTI, XORI, SLLI etc.
    constant OPCODE_RTYPE_ARITH  : std_logic_vector(6 downto 0) := "0110011"; -- ADD, SUB, SLL, SLT etc.
    constant OPCODE_LUI          : std_logic_vector(6 downto 0) := "0110111"; -- Loads upper immediate
    constant OPCODE_AUIPC        : std_logic_vector(6 downto 0) := "0010111"; -- Add upper immediate to PC
    constant OPCODE_JALR         : std_logic_vector(6 downto 0) := "1100111"; -- For target address calculation

    -- RISC-V Funct3 codes (relevant for ALU operation determination)
    constant FUNCT3_ADD_SUB_ADDI_BEQ_LB_SB : std_logic_vector(2 downto 0) := "000";
    constant FUNCT3_SLL_SLLI_BNE_LH_SH   : std_logic_vector(2 downto 0) := "001";
    constant FUNCT3_SLT_SLTI_LW_SW     : std_logic_vector(2 downto 0) := "010";
    constant FUNCT3_SLTU_SLTIU         : std_logic_vector(2 downto 0) := "011";
    constant FUNCT3_XOR_XORI_BLT_LBU   : std_logic_vector(2 downto 0) := "100";
    constant FUNCT3_SRL_SRA_SRLI_SRAI_BGE_LHU : std_logic_vector(2 downto 0) := "101";
    constant FUNCT3_OR_ORI_BLTU        : std_logic_vector(2 downto 0) := "110";
    constant FUNCT3_AND_ANDI_BGEU      : std_logic_vector(2 downto 0) := "111";

    -- Funct7 bit 5 (Instruction[30]) distinguishes SUB/SRA from ADD/SRL, and SRAI from SRLI
    constant FUNCT7_BIT5_IS_0 : std_logic := '0';
    constant FUNCT7_BIT5_IS_1 : std_logic := '1';

    -- ALU Operation Encodings for ALUOp_o
    -- These must match the operations supported by your actual ALU module
    constant ALU_OP_ADD     : std_logic_vector(3 downto 0) := "0000";
    constant ALU_OP_SUB     : std_logic_vector(3 downto 0) := "0001";
    constant ALU_OP_OR      : std_logic_vector(3 downto 0) := "0010";
    constant ALU_OP_AND     : std_logic_vector(3 downto 0) := "0011";
    constant ALU_OP_XOR     : std_logic_vector(3 downto 0) := "0100";
    constant ALU_OP_SLT     : std_logic_vector(3 downto 0) := "0101"; -- Set Less Than (signed)
    constant ALU_OP_SLTU    : std_logic_vector(3 downto 0) := "0110"; -- Set Less Than Unsigned
    constant ALU_OP_SLL     : std_logic_vector(3 downto 0) := "0111"; -- Shift Logical Left
    constant ALU_OP_SRL     : std_logic_vector(3 downto 0) := "1000"; -- Shift Logical Right
    constant ALU_OP_SRA     : std_logic_vector(3 downto 0) := "1001"; -- Shift Arithmetic Right
    constant ALU_OP_COPY_B  : std_logic_vector(3 downto 0) := "1010"; -- Pass ALU input B to output (for LUI)
    
    -- Default ALU operation (e.g., for JAL or unrecognized instructions)
    -- Using ADD as a default is often safe, or use "XXXX" if you want synthesis to optimize
    constant ALU_OP_DEFAULT : std_logic_vector(3 downto 0) := ALU_OP_ADD;

begin

    process(Opcode_i, Funct3_i, Funct7_i)
    begin
        -- Default ALU operation
        ALUOp_o <= ALU_OP_DEFAULT;

        case Opcode_i is
            when OPCODE_RTYPE_ARITH => -- R-Type: ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
                case Funct3_i is
                    when FUNCT3_ADD_SUB_ADDI_BEQ_LB_SB => -- ADD or SUB
                        if Funct7_i(5) = FUNCT7_BIT5_IS_0 then -- ADD
                            ALUOp_o <= ALU_OP_ADD;
                        else -- SUB (Funct7_i(5) = '1')
                            ALUOp_o <= ALU_OP_SUB;
                        end if;
                    when FUNCT3_SLL_SLLI_BNE_LH_SH =>   -- SLL
                        ALUOp_o <= ALU_OP_SLL;
                    when FUNCT3_SLT_SLTI_LW_SW =>     -- SLT
                        ALUOp_o <= ALU_OP_SLT;
                    when FUNCT3_SLTU_SLTIU =>         -- SLTU
                        ALUOp_o <= ALU_OP_SLTU;
                    when FUNCT3_XOR_XORI_BLT_LBU =>   -- XOR
                        ALUOp_o <= ALU_OP_XOR;
                    when FUNCT3_SRL_SRA_SRLI_SRAI_BGE_LHU => -- SRL or SRA
                        if Funct7_i(5) = FUNCT7_BIT5_IS_0 then -- SRL
                            ALUOp_o <= ALU_OP_SRL;
                        else -- SRA (Funct7_i(5) = '1')
                            ALUOp_o <= ALU_OP_SRA;
                        end if;
                    when FUNCT3_OR_ORI_BLTU =>        -- OR
                        ALUOp_o <= ALU_OP_OR;
                    when FUNCT3_AND_ANDI_BGEU =>      -- AND
                        ALUOp_o <= ALU_OP_AND;
                    when others =>
                        ALUOp_o <= ALU_OP_DEFAULT; -- Should not be reached for valid R-type
                end case;

            when OPCODE_ITYPE_ARITH => -- I-Type: ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
                case Funct3_i is
                    when FUNCT3_ADD_SUB_ADDI_BEQ_LB_SB => ALUOp_o <= ALU_OP_ADD;  -- ADDI
                    when FUNCT3_SLT_SLTI_LW_SW     => ALUOp_o <= ALU_OP_SLT;  -- SLTI
                    when FUNCT3_SLTU_SLTIU         => ALUOp_o <= ALU_OP_SLTU; -- SLTIU
                    when FUNCT3_XOR_XORI_BLT_LBU   => ALUOp_o <= ALU_OP_XOR;  -- XORI
                    when FUNCT3_OR_ORI_BLTU        => ALUOp_o <= ALU_OP_OR;   -- ORI
                    when FUNCT3_AND_ANDI_BGEU      => ALUOp_o <= ALU_OP_AND;  -- ANDI
                    when FUNCT3_SLL_SLLI_BNE_LH_SH => -- SLLI (Funct7_i(5) will be '0' for valid SLLI)
                        ALUOp_o <= ALU_OP_SLL;
                    when FUNCT3_SRL_SRA_SRLI_SRAI_BGE_LHU => -- SRLI or SRAI
                        if Funct7_i(5) = FUNCT7_BIT5_IS_0 then -- SRLI
                            ALUOp_o <= ALU_OP_SRL;
                        else -- SRAI (Funct7_i(5) = '1')
                            ALUOp_o <= ALU_OP_SRA;
                        end if;
                    when others =>
                        ALUOp_o <= ALU_OP_DEFAULT; -- Should not be reached for valid I-type arithmetic
                end case;

            when OPCODE_LOAD | OPCODE_STORE => -- For address calculation: rs1 + imm
                ALUOp_o <= ALU_OP_ADD;

            when OPCODE_BRANCH => -- For comparison logic
                case Funct3_i is
                    when FUNCT3_ADD_SUB_ADDI_BEQ_LB_SB | FUNCT3_SLL_SLLI_BNE_LH_SH => -- BEQ, BNE (uses rs1 - rs2)
                        ALUOp_o <= ALU_OP_SUB;
                    when FUNCT3_XOR_XORI_BLT_LBU | FUNCT3_SRL_SRA_SRLI_SRAI_BGE_LHU => -- BLT, BGE (uses signed comparison)
                        ALUOp_o <= ALU_OP_SLT;
                    when FUNCT3_OR_ORI_BLTU | FUNCT3_AND_ANDI_BGEU => -- BLTU, BGEU (uses unsigned comparison)
                        ALUOp_o <= ALU_OP_SLTU;
                    when others =>
                        ALUOp_o <= ALU_OP_DEFAULT; -- Should not be reached for valid Branch
                end case;

            when OPCODE_LUI => -- Load Upper Immediate
                ALUOp_o <= ALU_OP_COPY_B; -- Assumes immediate is on ALU input B and datapath handles shift

            when OPCODE_AUIPC => -- Add Upper Immediate to PC
                ALUOp_o <= ALU_OP_ADD; -- PC + imm 

            when OPCODE_JALR => -- Jump and Link Register
                ALUOp_o <= ALU_OP_ADD; -- rs1 + imm for target address

            -- For other opcodes (like JAL, FENCE, ECALL, EBREAK which don't use the ALU
            -- in the same way, or for invalid opcodes), ALUOp_o remains ALU_OP_DEFAULT.
            when others =>
                ALUOp_o <= ALU_OP_DEFAULT;
        end case;
    end process;

end architecture Behavioral; 