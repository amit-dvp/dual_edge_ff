-- Date: 24/10/26
-- Author : Amit S. 
-- Design description:
--
--     this is testbench for dual clock flip flop check


library ieee;
use ieee.std_logic_1164.all;


entity dual_clock_ff_tb is
end entity;


architecture arc of dual_clock_ff_tb is
    
    constant C_CLK_PERIOD : time := 20ns;
    constant C_RST_PERIOD : time := 29ns;

    signal rst_sig      : std_logic:='1';
    signal d_in_sig     : std_logic:='0';
    signal clk_sig      : std_logic:='0';
    signal rst_f_sig    : std_logic;
    signal rst_r_sig    : std_logic;
    signal d_out_0_sig  : std_logic;
    signal d_out_1_sig  : std_logic;
    signal d_out_2_sig  : std_logic;
    
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
    
 begin

        rst_sig <= '0' after C_RST_PERIOD;

        -- reset synchronizer to falling clock edge 
        rst_sync_f_inst : rst_sync_f 
        generic map (
            G_STAGES_NUM => 3         -- Number of synchronization FFs
        )
        port map ( 
            clk              => clk_sig,   -- clock for reset synchronization
            rst_async_in     => rst_sig,   -- Asynchronous reset input  (active high)
            rst_sync_out_f   => rst_f_sig  -- Synchronized reset output (active high)
        );


        -- reset synchronizer to rising clock edge 
        rst_sync_r_inst : rst_sync_r 
        generic map (
            G_STAGES_NUM => 3         -- Number of synchronization FFs
        )
        port map( 
            clk              => clk_sig,   -- clock for reset synchronization
            rst_async_in     => rst_sig,   -- Asynchronous reset input  (active high)
            rst_sync_out_r   => rst_r_sig  -- Synchronized reset output (active high)
        );


        -- clock generation
        clk_sig <= not clk_sig after C_CLK_PERIOD/2;

        process
            begin
                wait for  C_CLK_PERIOD*10;
                wait until rising_edge(clk_sig);
                wait for C_CLK_PERIOD-1 ns;
                d_in_sig <= '1';
                wait until rising_edge(clk_sig);
                wait for (C_CLK_PERIOD/2)*4;
                wait until falling_edge(clk_sig);
                wait for C_CLK_PERIOD-1 ns;
                d_in_sig <= '0';
                wait until rising_edge(clk_sig);
                wait for (C_CLK_PERIOD/2)*2;
                wait until rising_edge(clk_sig);
                wait for C_CLK_PERIOD-1 ns;                
                d_in_sig <= '1';
                wait until rising_edge(clk_sig);
                wait for (C_CLK_PERIOD/2)*2;
                wait until falling_edge(clk_sig);
                wait for C_CLK_PERIOD-1 ns;
                d_in_sig <= '0';                
                
                
                
                
                wait;
        end process;


        dual_clock_ff_inst0 : dual_clock_ff 
            port map(
                d_in        => d_in_sig, 
                clk         => clk_sig,
                d_out       => d_out_0_sig,
                rst_r       => rst_r_sig, -- reset syncronous with rising edge of clock
                rst_n       => rst_f_sig  -- reset synchronous with falling edge of clock
        );

        -- second stage
        dual_clock_ff_inst1 : dual_clock_ff 
            port map(
                d_in        => d_out_0_sig, 
                clk         => clk_sig,
                d_out       => d_out_1_sig,
                rst_r       => rst_r_sig, -- reset syncronous with rising edge of clock
                rst_n       => rst_f_sig  -- reset synchronous with falling edge of clock
        );
        
        -- third stage
        dual_clock_ff_inst2 : dual_clock_ff 
            port map(
                d_in        => d_out_1_sig, 
                clk         => clk_sig,
                d_out       => d_out_2_sig,
                rst_r       => rst_r_sig, -- reset syncronous with rising edge of clock
                rst_n       => rst_f_sig  -- reset synchronous with falling edge of clock
        );        
        
        
end ;    