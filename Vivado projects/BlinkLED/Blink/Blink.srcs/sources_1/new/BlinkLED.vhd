----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/30/2026 02:01:23 PM
-- Design Name: 
-- Module Name: BlinkLED - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity BlinkLED is
    Port ( LED : out STD_LOGIC_VECTOR (1 downto 0);
           clk, reset : in STD_LOGIC);
end BlinkLED;

architecture Behavioral of BlinkLED is
    Signal LED_Temp: unsigned(1 downto 0);
    Signal Clk_Divide: unsigned(25 downto 0);
begin
    process(clk, reset) begin
        if (reset = '0') then
            LED_Temp<= "00";
        else
            if (rising_edge(clk)) then
                Clk_Divide<= Clk_Divide + 1;
                if (ClK_Divide = TO_UNSIGNED(50000000, 26)) then 
                    LED_Temp<= LED_Temp + 1 ;
                    Clk_Divide <= (others => '0');
                end if;
            end if;
        end if;
    end process;
    LED<= not std_logic_vector(LED_Temp);

end Behavioral;
