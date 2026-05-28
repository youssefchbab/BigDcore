----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/28/2026 12:34:40 PM
-- Design Name: 
-- Module Name: Memory Mapping - arch
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: The unit manages memory mapping for different devices
--  (RAM, UART Registers......)
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Memory_Mapping is
    Port ( 
        address_bus : in STD_LOGIC_VECTOR (31 downto 0);
        RAM_EN : out std_logic;
        UART_EN: out std_logic
    );
end Memory_Mapping;

architecture arch of Memory_Mapping is

    --Constant Declaration
    constant DRAM_Start : integer := 268435456; -- 10000000H = 268435456 DEC
    constant DRAM_END   : integer := 536870911; -- 1FFFFFFFH = 536870911 DEC
    constant UART_Start : integer := 536870912; -- 20000000H = 536870912 DEC
    constant UART_END   : integer := 536871167; -- 200000FFH = 536871167 DEC

begin
    process(address_bus) begin
        if (address_bus >= std_logic_vector(to_unsigned(DRAM_Start, 32)) or address_bus < std_logic_vector(to_unsigned(DRAM_END, 32))) then
            RAM_EN<= '1';
        else
            RAM_EN<= '0';
        end if;

        if (address_bus >= std_logic_vector(to_unsigned(UART_Start, 32)) or address_bus < std_logic_vector(to_unsigned(UART_END, 32))) then
            UART_EN<= '1';
        else
            UART_EN<= '0';
        end if;
     end process;
end arch;
