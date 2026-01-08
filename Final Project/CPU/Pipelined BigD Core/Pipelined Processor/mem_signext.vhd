Library ieee;
use ieee.std_logic_1164.all;
--	This circuit signExtend or ZeroExtend bytes or half words coming from memory to the reg_file.
entity Mem_SignExt is	
	 port(Mem_in: in std_logic_vector(31 downto 0);
	 	 Alu_Lsb: in std_logic_vector(1 downto 0);
		 Sel: in std_logic_vector(2 downto 0);
		 To_Reg: out std_logic_vector(31 downto 0));
end entity;

architecture arch of Mem_SignExt is
	Signal Non_Extended_half: std_logic_vector(15 downto 0);
	Signal Non_Extended_byte: std_logic_vector(7 downto 0);
Begin 
	--The Skewed cases are Written to make Mem_Ext_cntr = Funct3
	Process (Alu_Lsb, Mem_in) Begin
		Case Alu_Lsb is
			when "00"=> Non_Extended_byte<= Mem_in(7 downto 0);
				Non_Extended_half<= Mem_in(15 downto 0);
			when "01"=> Non_Extended_byte<= Mem_in(15 downto 8);
				Non_Extended_half<= Mem_in(31 downto 16);
			when "10"=> Non_Extended_byte<= Mem_in(23 downto 16);
				Non_Extended_half<= Mem_in(15 downto 0);
			when "11"=> Non_Extended_byte<= Mem_in(31 downto 24);
				Non_Extended_half<= Mem_in(31 downto 16);
			when others => Non_Extended_byte<= (others =>'-');
				Non_Extended_half<= (others =>'-');
		end case;
	end process;
	Process(Sel, Non_Extended_byte, Non_Extended_half) Begin 
		Case Sel is 
			when "010"=> 
						 To_Reg<= Mem_in;
			--ZeroExt for Unsigned Values			
			when "100"=>  To_Reg<= (31 downto 8=>'0') & Non_Extended_byte;
			when "101"=>  To_Reg<= (31 downto 16=>'0') & Non_Extended_half;
			--SignExt for Signed values
			when "000"=>  To_Reg<= (31 downto 8=>Mem_in(7))&  Non_Extended_byte;
			when "001"=>  To_Reg<= (31 downto 16=>Mem_in(15)) & Non_Extended_half;
			when others=> To_Reg<= (others=>'Z');
		end case;
	end process;
end architecture;
			