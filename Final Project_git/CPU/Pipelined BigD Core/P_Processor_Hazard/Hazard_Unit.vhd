Library ieee;
use ieee.std_logic_1164.all;

entity Hazard_Unit is
    port(
        RsD1, RsD2: in std_logic_vector(4 downto 0);
        RsE1, RsE2: in std_logic_vector(4 downto 0);
        RdE,RdM,RdW: in std_logic_vector(4 downto 0);
        Pc_Select_Initial: in std_logic_vector(1 downto 0) ;
        RegWriteM, RegWriteW: in std_logic;
        Writeback_cntr: in std_logic; --The Lsb is enough
        Pc_Select: in std_logic;--MSB
        ForwardA, ForwardB: out std_logic_vector(1 downto 0);
        StallF, StallD: out std_logic;
        FlushE, FlushD: out std_logic
        
    );
end entity;

architecture arch of Hazard_Unit is
    Signal Lw_stall: std_logic;
Begin 
    process(RsD1, Lw_stall, Pc_Select_Initial, Writeback_cntr, Pc_Select, RsD2, RsE1, RsE2, RdE,RdM,RdW, RegWriteM, RegWriteW) Begin
                --Forwards to Reg1
        if(RdM=RsE1 and (Pc_Select_Initial="11" or RegWriteM='1') and RsE1/= "00000") then
            ForwardA<= "10";
                
        elsif(RdW=RsE1 and (Pc_Select_Initial="11" or RegWriteW='1') and RsE1/= "00000") then
            ForwardA<= "01";
        else
            ForwardA<= "00";
        end if;
            --Forwards to Reg2
        if(RdM=RsE2 and (Pc_Select_Initial="11" or RegWriteM='1') and RsE2/= "00000") then
            ForwardB<= "10";
                
        elsif(RdW=RsE2 and (Pc_Select_Initial="11" or RegWriteW='1') and RsE2/= "00000") then
            ForwardB<= "01";
        else
            ForwardB<= "00";
        end if;
            --Stalling when Lw inst is detected in Ex stage
        if(Writeback_cntr='1' and (RsD1=RdE or RsD2=RdE)) then
            Lw_stall<= '1';
        else
            Lw_stall<= '0';
        end if;
    end process;
    
    StallF<= Lw_stall;
    StallD<= Lw_stall;
    FlushE<= Lw_stall or Pc_Select;
    FlushD<= Pc_Select;
end arch;