library ieee;
use ieee.std_logic_1164.all;

entity P_Control_Unit is
    port(
        clk, reset: in std_logic;
        Zero, Alu_LSB: in std_logic;
        Funct7: in std_logic_vector(6 downto 0) ;
        Opcode: in std_logic_vector(6 downto 0) ;
        Funct3: in std_logic_vector(2 downto 0) ;
        Alu_control: out std_logic_vector(3 downto 0) ;--Done
        ImmExt: out std_logic_vector(2 downto 0);--Done
        Word_Half_Byte: out std_logic_vector(1 downto 0);--Done
        RegWrite: out std_logic;
        MemWrite: out std_logic;--Done
        Mem_Ext_cntr: out std_logic_vector(2 downto 0);
        Write_Back_cntr: out std_logic_vector(1 downto 0);
        Pc_clr: out std_logic;--Done
        Pc_select: out std_logic_vector(1 downto 0);--Done
        Alu_input: out std_logic;--Done
        Alu_input_for_auipc_and_lui: out std_logic_vector(1 downto 0);--Done
        Reg_WriteM: out std_logic;--Used by hazard unit
        Write_backE: out std_logic;--Used by hazard unit
        FlushE: in std_logic
    );
end entity;

architecture arch of P_Control_Unit is
    --Component Declaration
    component Alu_cntr is
        port(
            Opcode: in std_logic_vector(6 downto 0) ;
            Funct3: in std_logic_vector(2 downto 0) ;
            Funct7_Bit5: in std_logic;--Only need Bit-5
            Alu_Op: out std_logic_vector(3 downto 0)
        );
    end component;
    component P_Main_unit is
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
    end component;
    component Excution_Flow is
        port(
            Pc_Select_initial: in std_logic_vector(1 downto 0);
            Branch_Mode: in std_logic_vector(2 downto 0) ;
            Zero: in std_logic;
            Alu_LSB: in std_logic;
            Pc_Select_Final: out std_logic_vector(1 downto 0)
        );
    end component;
    component RegEn is
        generic(N: integer := 21);
        port (
            clk,Reset: in std_logic;
            En, Flush: in std_logic;
            NoN: in std_logic_vector(N-1 downto 0) ;
            D: in std_logic_vector(N-1 downto 0) ;
            Q: out std_logic_vector(N-1 downto 0)

        ) ;
    end component;
    component RegEn_9bit is
        generic(N: integer := 9);
        port (
            clk,Reset: in std_logic;
            En, Flush: in std_logic;
            NoN: in std_logic_vector(N-1 downto 0) ;
            D: in std_logic_vector(N-1 downto 0) ;
            Q: out std_logic_vector(N-1 downto 0)

        ) ;
    end component;
    component RegEn_6bit is
        generic(N: integer := 6);
        port (
            clk,Reset: in std_logic;
            En, Flush: in std_logic;
            NoN: in std_logic_vector(N-1 downto 0) ;
            D: in std_logic_vector(N-1 downto 0) ;
            Q: out std_logic_vector(N-1 downto 0)

        ) ;
    end component;
    --Signal Declaration
    Signal RegWrite_Sig, MemWrite_Sig: std_logic;
    Signal Word_Half_Byte_Sig, Write_Back_cntr_Sig: std_logic_vector(1 downto 0);
    Signal Mem_Ext_cntr_Sig, ImmExt_Sig: std_logic_vector(2 downto 0);
    Signal Alu_control_Sig: std_logic_vector(3 downto 0);
    Signal Pc_clr_Sig, Alu_input_Sig: std_logic;
    Signal Pc_select_Sig, Alu_input_for_auipc_and_lui_Sig: std_logic_vector(1 downto 0);
    Signal Branch_Mode_Sig: std_logic_vector(2 downto 0);
    Signal Control_bus, Control_bus_PLR3: std_logic_vector(20 downto 0); -- Holds the control signals between cycles
    Signal Control_bus_PLR4, Control_bus_PLR3_Reduced: std_logic_vector(8 downto 0);
    Signal Control_bus_PLR5, Control_bus_PLR4_Reduced: std_logic_vector(5 downto 0);

Begin
    --Decode Cycle
    Alu_Control_Unit: Alu_cntr port map(Opcode, Funct3, Funct7(5), Alu_control_Sig);
    Main_Control_Unit: P_Main_unit port map(
        Reset,
        Funct3,
        Opcode,
        ImmExt_Sig,
        Word_Half_Byte_Sig,
        RegWrite_Sig,
        MemWrite_Sig,
        Mem_Ext_cntr_Sig,
        Write_Back_cntr_Sig,
        Pc_clr,
        Pc_select_Sig,
        Alu_input_Sig,
        Branch_Mode_Sig,
        Alu_input_for_auipc_and_lui_Sig
    );
    ImmExt<= ImmExt_Sig;
    Control_bus(20 downto 17)<= Alu_control_Sig;
    Control_bus(16 downto 15)<= Word_Half_Byte_Sig;
    Control_bus(14)<= RegWrite_Sig;
    Control_bus(13)<= MemWrite_Sig;
    Control_bus(12 downto 10)<= Mem_Ext_cntr_Sig;
    Control_bus(9 downto 8)<= Write_Back_cntr_Sig;
    Control_bus(7 downto 6)<= Pc_select_Sig;
    Control_bus(5)<= Alu_input_Sig;
    Control_bus(4 downto 2)<= Branch_Mode_Sig;
    Control_bus(1 downto 0)<= Alu_input_for_auipc_and_lui_Sig;
    Control_Signals_PLR03: RegEn port map(
        clk, reset,
        '0', FlushE,
        "000000000000001000000",
        Control_bus,
        Control_bus_PLR3
    );
    --Execute Cycle
    Alu_input<= Control_bus_PLR3(5);
    Alu_control<= Control_bus_PLR3(20 downto 17);
    Alu_input_for_auipc_and_lui<= Control_bus_PLR3(1 downto 0);
    Excute_Flow_cntr: Excution_Flow port map(
        Control_bus_PLR3(7 downto 6),
        Control_bus_PLR3(4 downto 2),
        Zero, Alu_LSB,
        Pc_select
    );
    Control_bus_PLR3_Reduced<= Control_bus_PLR3 (16 downto 8);
    Control_Signals_PLR04: RegEn_9bit port map(
        clk,reset,
        '0','0',
        (others=>'0'),
        Control_bus_PLR3_Reduced,
        Control_bus_PLR4
    );
    Write_backE<= Control_bus_PLR3(8);
    --Memory Cycle
    Word_Half_Byte<= Control_bus_PLR4(8 downto 7);
    MemWrite<= Control_bus_PLR4(5);
    Control_bus_PLR4_Reduced<= Control_bus_PLR4(6) & Control_bus_PLR4(4 downto 0);
    Control_Signals_PLR05: RegEn_6bit port map(
        clk, reset,
        '0','0',
        (others=>'0'),
        Control_bus_PLR4_Reduced,
        Control_bus_PLR5
    );
    Reg_WriteM<= Control_bus_PLR4(6);

    --Writeback Cycle
    RegWrite<= Control_bus_PLR5(5);
    Mem_Ext_cntr<= Control_bus_PLR5(4 downto 2);
    Write_Back_cntr<= Control_bus_PLR5(1 downto 0);
end arch;