-- Date: 24/10/26
-- Author : Amit S. 
-- Design description:
--
--     testbench for top module


library ieee;
use ieee.std_logic_1164.all;

entity top_tb is
end entity;


architecture arc of top_tb is
    
   component top is
        port(
            clk_in  : in std_logic;
            rst_in  : in std_logic;
            d_out   : out std_logic
        );
    end component;   

    signal   clk_sig : std_logic:='0';
    signal   rst_sig : std_logic:='1';
    signal   d_out : std_logic;
    constant C_CLK_PERIOD : time := 5 ns;
    constant C_RESET_PERIOD : time := 300 ns;

begin


   clk_sig <= not clk_sig after C_CLK_PERIOD/2; 
   rst_sig  <= '0' after C_RESET_PERIOD;

   top_inst : top 
        port map(
            clk_in  => clk_sig,
            rst_in  => rst_sig, 
            d_out   => d_out
        );

end arc;    

