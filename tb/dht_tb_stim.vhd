-------------------------------------------------------------------------------
-- dht_tb_stim.vhd
--
-- Testbench stimulus for the N-point DHT-IV modules.
--
-- Reads the input part (x0 .. x(N-1)) of every vector line of FILE_NAME
-- (format: see scripts/gen_vectors.py) and applies one vector per clock
-- cycle with valid = '1', i.e. at full pipeline throughput. Lines starting
-- with '#' and empty lines are skipped. After the last vector valid returns
-- to '0' and done is set.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;
use std.textio.all;
use work.fixed_types_pkg.all;

entity dht_tb_stim is
    generic (
        N         : positive;
        FILE_NAME : string
    );
    port (
        clk   : in  std_logic;
        rst   : in  std_logic;
        x     : out sfix32_vector(0 to N - 1);
        valid : out std_logic;
        done  : out boolean
    );
end entity dht_tb_stim;

architecture sim of dht_tb_stim is
begin

    process
        file     f : text;
        variable l : line;
        variable v : integer;
    begin
        x     <= (others => SFIX32_ZERO);
        valid <= '0';
        done  <= false;
        wait until rst = '0';

        file_open(f, FILE_NAME, read_mode);
        while not endfile(f) loop
            readline(f, l);
            next when l'length = 0 or l(1) = '#';

            wait until rising_edge(clk);
            for i in 0 to N - 1 loop
                read(l, v);
                x(i) <= to_sfixed(std_logic_vector(to_signed(v, 32)), 15, -16);
            end loop;
            valid <= '1';
        end loop;
        file_close(f);

        wait until rising_edge(clk);
        valid <= '0';
        done  <= true;
        wait;
    end process;

end architecture sim;
