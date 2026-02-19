Library ieee;
use ieee.std_logic_1164.all;
use ieee.Numeric_std.all;
--Credit to tim from Stack overflow.
entity ALU is
	generic(Alu_bits: integer:= 32);
	port(A,B: in std_logic_vector(Alu_bits-1 downto 0);
		 Alu_cntr: in std_logic_vector(3 downto 0);
		 Alu_out: out std_logic_vector(Alu_bits-1 downto 0);
		 Zero_flag: out std_logic);
end entity;

Architecture arch of ALU is
	constant Alu_MSB: integer := Alu_bits - 1;--Alu_bits = 31
	--Contants holding command values
	constant CMD_add : std_logic_vector := x"0";
	constant CMD_sub : std_logic_vector := x"1";
	constant CMD_and : std_logic_vector := x"2";
	constant CMD_or  : std_logic_vector := x"3";
	constant CMD_xor : std_logic_vector := x"4";
	constant CMD_slt : std_logic_vector := x"5";
	constant CMD_sltu: std_logic_vector := x"6";
	constant CMD_sll : std_logic_vector := x"7";
	constant CMD_slr : std_logic_vector := x"8";
	constant CMD_sar : std_logic_vector := x"9";
	
	
	subtype TALUregister is std_logic_vector(Alu_MSB downto 0);
	subtype TALUregisterx is std_logic_vector(Alu_bits downto 0); 
	subtype TALUregister_U is unsigned(Alu_MSB downto 0);
	subtype TALUregisterx_U is unsigned(Alu_bits downto 0);

	
	constant One : TALUregister := (Alu_MSB downto 1=> '0') & '1';
	constant Zero : TALUregister := (others=> '0');
	
	--Signal shamt : integer;
	Signal slr, sll_inst: unsigned (Alu_MSB downto 0);
	Signal sar,A_S : Signed(Alu_MSB downto 0);
	Signal slt, sltu, Alu_Result: TALUregister;
	Signal sub, add, A_Signed, B_Signed: TALUregisterx;
	Signal A_U: TALUregister_U;
	Signal A_Unsigned, B_Unsigned: TALUregisterx_U;
Begin 
	
	A_Unsigned <= TALUregisterx_U('0' & A);
	B_Unsigned <= TALUregisterx_U('0' & B);
	A_U<= TALUregister_U(A);
	A_Signed<= '0' & A;
	A_S<= signed(A);
	B_Signed<= '0' & B;
	--shamt <= integer(B);
	--Add and Sub operation 
	add<= TALUregisterx( signed(A_Signed) + signed(B_Signed));
	sub<= TALUregisterx( signed(A_Signed) - signed(B_Signed));
	--set less than 
	process(A_Signed, B_Signed) Begin
		if (A_Signed < B_Signed) then 
			slt<= One;
		else
			slt<= Zero;
		end if;
	end process;
	--set less than unsigned
	process(A_Unsigned,B_Unsigned) Begin
		if (A_Unsigned < B_Unsigned) then 
			sltu<= One;
		else
			sltu<= Zero;
		end if;
	end process;
	--Shift left logical 
	sll_inst<= Shift_left(unsigned(A_U), to_integer(unsigned(B)));
	--Shift Right Logical
	slr<= Shift_Right(A_U, to_integer(unsigned(B)));--unsigned type convertion
	--Shift Right Arithmetic
	sar<= Shift_Right(A_S, to_integer(unsigned(B)));
	--Command Control
	Process(A,B,slt,sltu,sll_inst,slr,sar,add,sub,Alu_cntr) Begin
		case Alu_cntr is
			When CMD_add => Alu_result<= add(Alu_MSB downto 0);
			when CMD_sub => Alu_result<= sub(Alu_MSB downto 0);
			When CMD_and => Alu_result<= A and B;
			When CMD_or  => Alu_result<= A or B;
			When CMD_xor => Alu_result<= A xor B;
			When CMD_slt => Alu_result<= slt;
			When CMD_sltu=> Alu_result<= sltu;
			When CMD_sll => Alu_result<= TALUregister(unsigned(sll_inst));
			When CMD_slr => Alu_result<= TALUregister(unsigned(slr));
			When CMD_sar => Alu_result<= TALUregister(signed(sar));
			When others  => Alu_result<= (others => 'Z');
		end case;
	end process;
	Alu_out<= Alu_result;
	--Flags
	Zero_Flag <= '1' when Alu_result= zero else '0';
end arch;