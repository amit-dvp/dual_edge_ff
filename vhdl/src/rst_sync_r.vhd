-- Date: 24/10/26
-- Author : Amit S. 
-- Design description:
--
--      reset synchronizer for Vivado for rising clock edge

library ieee;
use ieee.std_logic_1164.all;

entity rst_sync_r is
    generic (
        G_STAGES_NUM : positive := 3         -- Number of synchronization FFs
    );
    port ( 
        clk              : in  std_logic;   -- clock for reset synchronization
        rst_async_in     : in  std_logic;   -- Asynchronous reset input  (active high)
        rst_sync_out_r   : out std_logic    -- Synchronized reset output (active high)
    );
end entity;

architecture arc of rst_sync_r is

    signal sig_sync_ff : std_logic_vector(G_STAGES_NUM-1 downto 0);

    attribute ASYNC_REG : string;      -- Vivado attribute
    attribute SHREG_EXTRACT : string;  -- Vivado attribute

    attribute ASYNC_REG of sig_sync_ff : signal is "TRUE";   -- put FF's close
    attribute SHREG_EXTRACT of sig_sync_ff : signal is "NO"; -- use FF's , and prevent usage of SRL

begin

    process(clk, rst_async_in)
    begin
        if rst_async_in = '1' then
            sig_sync_ff <= (others => '1');
        elsif rising_edge(clk) then
            sig_sync_ff(0) <= '0';

            for i in 1 to G_STAGES_NUM-1 loop
                sig_sync_ff(i) <= sig_sync_ff(i-1);
            end loop;
        end if;
    end process;

    rst_sync_out_r <= sig_sync_ff(G_STAGES_NUM-1);

end architecture arc;