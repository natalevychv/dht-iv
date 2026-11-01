-------------------------------------------------------------------------------
-- dht_tb_check.vhd
--
-- Testbench output checker for the N-point DHT-IV modules.
--
-- On every rising clock edge with valid = '1' reads the next vector line of
-- FILE_NAME and compares y with its expected part (y0 .. y(N-1)). The error
-- is measured in Q15.16 LSB; an output is reported as failed when the error
-- exceeds TOL_LSB (only the first MAX_REPORTS failures are printed). When
-- all vectors have been checked, a summary line tagged with TAG is printed
-- and done is set.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;
use std.textio.all;
use work.fixed_types_pkg.all;

entity dht_tb_check is
    generic (
        N           : positive;
        FILE_NAME   : string;
        TAG         : string;
        TOL_LSB     : natural;
        MAX_REPORTS : natural := 10
    );
    port (
        clk    : in  std_logic;
        valid  : in  std_logic;
        y      : in  sfix32_vector(0 to N - 1);
        done   : out boolean;
        errors : out natural
    );
end entity dht_tb_check;

architecture sim of dht_tb_check is
begin

    process
        file     f        : text;
        variable l        : line;
        variable o        : line;
        variable v        : integer;
        variable actual   : integer;
        variable err      : natural;
        variable max_err  : natural := 0;
        variable n_vec    : natural := 0;
        variable n_fail   : natural := 0;
    begin
        done   <= false;
        errors <= 0;

        file_open(f, FILE_NAME, read_mode);
        while not endfile(f) loop
            readline(f, l);
            next when l'length = 0 or l(1) = '#';

            wait until rising_edge(clk) and valid = '1';
            for i in 0 to N - 1 loop       -- skip the input part
                read(l, v);
            end loop;
            for k in 0 to N - 1 loop
                read(l, v);
                actual := to_integer(signed(to_slv(y(k))));
                err    := abs(actual - v);
                if err > max_err then
                    max_err := err;
                end if;
                if err > TOL_LSB then
                    n_fail := n_fail + 1;
                    if n_fail <= MAX_REPORTS then
                        write(o, "ERROR [" & TAG & "] vector " & integer'image(n_vec) &
                                 " y" & integer'image(k) & ": expected " &
                                 integer'image(v) & " received " &
                                 integer'image(actual) & " (" &
                                 integer'image(err) & " LSB)");
                        writeline(output, o);
                    end if;
                end if;
            end loop;
            n_vec := n_vec + 1;
        end loop;
        file_close(f);

        write(o, "[" & TAG & "] " & integer'image(n_vec) & " vectors, max error " &
                 integer'image(max_err) & " LSB, " & integer'image(n_fail) &
                 " outputs above " & integer'image(TOL_LSB) & " LSB");
        writeline(output, o);
        assert n_fail = 0 report TAG & ": test failed" severity error;

        errors <= n_fail;
        done   <= true;
        wait;
    end process;

end architecture sim;
