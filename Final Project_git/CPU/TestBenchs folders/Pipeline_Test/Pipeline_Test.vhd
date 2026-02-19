Library ieee; 
use ieee.std_logic_1164.all;

entity Pipeline_Test is
end entity;

architecture arch of Pipeline_Test is
    component P_FullProcessor is
        port (
            clk,Reset: in std_logic
        ) ;
    end component;
    constant clk_period : time := 20 ns;
    Signal clk, Reset: std_logic := '0';
Begin
    clk_process: Process begin
        loop
            clk<= '0';
            wait for 10 ns;
            clk<= '1';
            wait for 10 ns;
        end loop;
    end process;
    UUT: P_FullProcessor port map(clk, Reset);
    Stimulus: process Begin
        Reset<= '1';
        wait for clk_period*2;
        Reset<= '0';
        wait;
    end process;
end architecture;