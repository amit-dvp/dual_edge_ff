-- Date: 02/11/26
-- Author : Amit S. 
-- Design description:
--
-- 
--        Top-level design file containing a small design for evaluating
--        dual-edge flip-flop logic (rising and falling clock edges).
--        It meets timing at a 300 MHz clock on a Kintex-7 -1 speed-grade FPGA,
--        where it generates a pulse width of half a clock period (1.67 ns).



library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity top is
    port(
        clk_in  : in std_logic;
        rst_in  : in std_logic;
        d_out   : out std_logic
    );
end entity;    


architecture arc of top is

    signal narrow_pulse     : std_logic;
    signal clk              : std_logic;
    signal rst_f_sig        : std_logic;
    signal rst_r_sig        : std_logic;
    signal d_out_0_sig      : std_logic;
    signal d_out_1_sig      : std_logic;
    signal d_out_2_sig      : std_logic;

    component rst_sync_f is
        generic (
            G_STAGES_NUM : positive := 3         -- Number of synchronization FFs
        );
        port ( 
            clk              : in  std_logic;   -- clock for reset synchronization
            rst_async_in     : in  std_logic;   -- Asynchronous reset input  (active high)
            rst_sync_out_f   : out std_logic    -- Synchronized reset output (active high)
        );
    end component;
    
    component rst_sync_r is
        generic (
            G_STAGES_NUM : positive := 3         -- Number of synchronization FFs
        );
        port ( 
            clk              : in  std_logic;   -- clock for reset synchronization
            rst_async_in     : in  std_logic;   -- Asynchronous reset input  (active high)
            rst_sync_out_r   : out std_logic    -- Synchronized reset output (active high)
        );
    end component;

    component dual_clock_ff is
        port (

        d_in        : in std_logic;
        clk         : in std_logic;
        rst_r       : in std_logic; -- reset syncronous with rising edge of clock
        rst_n       : in std_logic;  -- reset synchronous with falling edge of clock
        d_out       : out std_logic

    );
    end component;

    component narrow_pulse_gen is
        port( 
            rst_p       : in std_logic;
            rst_n       : in std_logic;
            clk         : in std_logic;
            pulse_out   : out std_logic
        );
    end component;

    begin

        clk_bufg_inst : BUFG
            port map (I => clk_in, 
                      O => clk);
  
        -- reset synchronizer to falling clock edge 
        rst_sync_f_inst : rst_sync_f 
        generic map (
            G_STAGES_NUM => 3         -- Number of synchronization FFs
        )
        port map ( 
            clk              => clk,   -- clock for reset synchronization
            rst_async_in     => rst_in,   -- Asynchronous reset input  (active high)
            rst_sync_out_f   => rst_f_sig  -- Synchronized reset output (active high)
        );


        -- reset synchronizer to rising clock edge 
        rst_sync_r_inst : rst_sync_r 
        generic map (
            G_STAGES_NUM => 3         -- Number of synchronization FFs
        )
        port map( 
            clk              => clk,   -- clock for reset synchronization
            rst_async_in     => rst_in,   -- Asynchronous reset input  (active high)
            rst_sync_out_r   => rst_r_sig  -- Synchronized reset output (active high)
        );


        -- generate pulse between rising and falling clock edge
        pulse_gen_inst: narrow_pulse_gen 
            port map( 
                rst_p       => rst_r_sig, 
                rst_n       => rst_f_sig, 
                clk         => clk, 
                pulse_out   => narrow_pulse
            );

        dual_clock_ff_inst0 : dual_clock_ff 
            port map(
                d_in        => narrow_pulse, 
                clk         => clk,
                d_out       => d_out_0_sig,
                rst_r       => rst_r_sig, -- reset syncronous with rising edge of clock
                rst_n       => rst_f_sig  -- reset synchronous with falling edge of clock
        );

        -- second stage
        dual_clock_ff_inst1 : dual_clock_ff 
            port map(
                d_in        => d_out_0_sig, 
                clk         => clk,
                d_out       => d_out_1_sig,
                rst_r       => rst_r_sig, -- reset syncronous with rising edge of clock
                rst_n       => rst_f_sig  -- reset synchronous with falling edge of clock
        );
        
        -- third stage
        dual_clock_ff_inst2 : dual_clock_ff 
            port map(
                d_in        => d_out_1_sig, 
                clk         => clk,
                d_out       => d_out_2_sig,
                rst_r       => rst_r_sig, -- reset syncronous with rising edge of clock
                rst_n       => rst_f_sig  -- reset synchronous with falling edge of clock
        );   



        -- ODDR: Output Double Data Rate Output Register with Set, Reset
        --       and Clock Enable.
        --       7 Series-- Xilinx HDL Language Template, version 2026.1
        ODDR_inst : ODDR
        generic map(
            DDR_CLK_EDGE => "OPPOSITE_EDGE",    -- "OPPOSITE_EDGE" or "SAME_EDGE"
            INIT => '0',                        -- Initial value for Q port ('1' or '0')
            SRTYPE => "SYNC"                    -- Reset Type ("ASYNC" or "SYNC")
            ) 
        port map (
            Q => d_out,             -- 1-bit DDR output
            C => clk,               -- 1-bit clock input
            CE => '1',              -- 1-bit clock enable input
            D1 => d_out_2_sig,      -- 1-bit data input (positive edge)
            D2 => d_out_2_sig,      -- 1-bit data input (negative edge)
            R => '0',               -- 1-bit reset input
            S => '0'                -- 1-bit set input
        );    




end arc;        