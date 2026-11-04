-- Date: 24/10/26
-- Author : Amit S. 
-- Design description:
--
--     this design implements dual clock flip flop


library ieee;
use ieee.std_logic_1164.all;

entity dual_clock_ff is
    port (

        d_in        : in std_logic;
        clk         : in std_logic;
        rst_r       : in std_logic; -- reset syncronous with rising edge of clock
        rst_n       : in std_logic;  -- reset synchronous with falling edge of clock
        d_out       : out std_logic

    );

end entity;   


architecture arc of dual_clock_ff is

    signal d_pos : std_logic;
    signal d_neg : std_logic;

    begin


        -- rising edge ff
        process(rst_r, clk)
            begin
                if rst_r = '1' then
                    d_pos <= '0';
                elsif clk'event and clk = '1' then
                    d_pos <= d_in xor d_neg;
                end if;    
        end process;
        
        
        --falling edge ff
        process(rst_n, clk)
            begin
                if rst_n = '1' then
                    d_neg <= '0';
                elsif clk'event and clk = '0' then
                    d_neg <= d_in xor d_pos;
                end if;    
        end process;

        d_out <= d_pos xor d_neg;

end arc;        


