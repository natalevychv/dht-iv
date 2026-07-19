-------------------------------------------------------------------------------
-- n3_tb.vhd
--
-- Testbench for the proposed N3 architecture.
--
-- 1) Applies three manually verified test vectors corresponding to the
--    columns of the DHT-IV matrix:
--       e0 = (1,0,0), e1 = (0,1,0), e2 = (0,0,1).
-- 2) Simulates the proposed and naive implementations in parallel and
--    verifies that both produce the expected results.
-- 3) Future work: replace the manual test set with vectors loaded from
--    the CSV files in the vectors/ directory.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use std.textio.all;
use work.fixed_types_pkg.all;

entity n3_tb is
end entity n3_tb;

architecture sim of n3_tb is

    constant CLK_PERIOD : time := 10 ns;
    constant TOL        : real := 1.0e-3;  -- comparison tolerance (Q15.16)

    signal clk      : std_logic := '0';
    signal rst      : std_logic := '1';
    signal valid_in : std_logic := '0';
    signal x_in     : sfix32_vector(0 to 2) := (others => (others => '0'));

    signal valid_out_p, valid_out_n : std_logic;
    signal y_p, y_n : sfix32_vector(0 to 2);

    signal sim_done : boolean := false;

    type real_vec3 is array (0 to 2) of real;
    type test_case is record
        input    : real_vec3;
        expected : real_vec3;
    end record;

    -- Reference test vectors:
    --   x = (1,0,0) -> ( 0.7887,  0.5774, -0.2113)
    --   x = (0,1,0) -> ( 0.5774, -0.5774,  0.5774)
    --   x = (0,0,1) -> (-0.2113,  0.5774,  0.7887)
    type test_array is array (0 to 2) of test_case;
    constant TESTS : test_array := (
        ((1.0, 0.0, 0.0), ( 0.7887,  0.5774, -0.2113)),
        ((0.0, 1.0, 0.0), ( 0.5774, -0.5774,  0.5774)),
        ((0.0, 0.0, 1.0), (-0.2113,  0.5774,  0.7887))
    );

begin

    ---------------------------------------------------------------------
    -- DUT: proposed architecture
    ---------------------------------------------------------------------
    dut_proposed : entity work.n3_prop_top
        port map (
            clk       => clk,
            rst       => rst,
            valid_in  => valid_in,
            x         => x_in,
            valid_out => valid_out_p,
            y         => y_p
        );

    ---------------------------------------------------------------------
    -- DUT: naive reference implementation
    ---------------------------------------------------------------------
    dut_naive : entity work.n3_naive
        port map (
            clk       => clk,
            rst       => rst,
            valid_in  => valid_in,
            x         => x_in,
            valid_out => valid_out_n,
            y         => y_n
        );

    ---------------------------------------------------------------------
    -- Clock generation
    ---------------------------------------------------------------------
    clk_gen : process
    begin
        while not sim_done loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    ---------------------------------------------------------------------
    -- Stimulus and result verification
    ---------------------------------------------------------------------
    stim : process
        variable l : line;

        procedure check(actual : real; expected : real; tag : string) is
        begin
            if abs(actual - expected) > TOL then
                write(l, string'("ERROR [") & tag & "] expected " &
                         real'image(expected) & " received " &
                         real'image(actual));
                writeline(output, l);
                assert false report "Test failed: " & tag severity error;
            else
                write(l, string'("OK    [") & tag & "] = " &
                         real'image(actual));
                writeline(output, l);
            end if;
        end procedure;

    begin
        -- Reset
        rst <= '1';
        wait for 3 * CLK_PERIOD;
        rst <= '0';
        wait until rising_edge(clk);

        for i in TESTS'range loop

            -- Apply the input vector for one clock cycle.
            x_in(0)  <= to_sfixed(TESTS(i).input(0), 15, -16);
            x_in(1)  <= to_sfixed(TESTS(i).input(1), 15, -16);
            x_in(2)  <= to_sfixed(TESTS(i).input(2), 15, -16);
            valid_in <= '1';
            wait until rising_edge(clk);
            valid_in <= '0';

            -- The naive implementation has a latency of 1 clock cycle,
            -- while the proposed architecture has a latency of 5 clock
            -- cycles. Wait for the proposed output. The naive output
            -- remains stored in its output register until the next
            -- valid input is applied.
            wait until rising_edge(clk) and valid_out_p = '1';
            wait until rising_edge(clk);

            check(to_real(y_p(0)), TESTS(i).expected(0),
                  "proposed y0 vector " & integer'image(i));
            check(to_real(y_p(1)), TESTS(i).expected(1),
                  "proposed y1 vector " & integer'image(i));
            check(to_real(y_p(2)), TESTS(i).expected(2),
                  "proposed y2 vector " & integer'image(i));

            check(to_real(y_n(0)), TESTS(i).expected(0),
                  "naive    y0 vector " & integer'image(i));
            check(to_real(y_n(1)), TESTS(i).expected(1),
                  "naive    y1 vector " & integer'image(i));
            check(to_real(y_n(2)), TESTS(i).expected(2),
                  "naive    y2 vector " & integer'image(i));

            wait for 2 * CLK_PERIOD;
        end loop;

        write(l, string'("=== All tests completed successfully ==="));
        writeline(output, l);

        sim_done <= true;
        wait;
    end process;

end architecture sim;

-------------------------------------------------------------------------------
-- TODO:
-- Replace the TESTS array with vectors loaded from CSV files located
-- in the vectors/ directory (e.g. 1000 test cases generated in Python).
-- Use std.textio (file_open, readline, read) and compare the results
-- using the check() procedure.
-------------------------------------------------------------------------------
