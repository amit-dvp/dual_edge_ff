-- Date: 24/10/26
-- Author : Amit S. 
-- Design description:
--
--      generates narrow pulse between rising and falling clock edge 
 
library ieee;
use ieee.std_logic_1164.all;

entity narrow_pulse_gen is
    port( 
        rst_p       : in std_logic;
        rst_n       : in std_logic;
        clk         : in std_logic;
        pulse_out   : out std_logic
    );
end entity;


architecture arc of narrow_pulse_gen is
    
    constant C_CNT_MAX : integer:= 50; -- maximum counter value

    signal counter : integer range 0 to C_CNT_MAX;
    signal step_p  : std_logic;
    signal step_n  : std_logic;


    begin

        -- rising edge counter
        process (rst_p,clk)
            begin
                if rst_p = '1' then
                    counter <= 0;
                elsif rising_edge(clk) then
                    if counter = C_CNT_MAX then
                        counter <= counter;
                    else 
                        counter <= counter + 1;
                    end if;         
                end if;    
        end process;


        -- rising edge step gen
        process (rst_p,clk)
            begin
                if rst_p = '1' then
                    step_p <= '0';
                elsif rising_edge(clk) then
                    if counter = C_CNT_MAX then
                        step_p <= '1';
                    end if;         
                end if;    
        end process;

        -- falling edge step gen
        process (rst_n,clk)
            begin
                if rst_n = '1' then
                    step_n <= '0';
                elsif falling_edge(clk) then
                    if step_p = '1' then
                        step_n <= '1';
                    end if;         
                end if;    
        end process;

        -- narrow pulse generation
        pulse_out <= step_p xor step_n;

end arc;