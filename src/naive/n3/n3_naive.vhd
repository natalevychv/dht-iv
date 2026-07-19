-------------------------------------------------------------------------------
-- n3_naive.vhd
--
-- Naive implementation of the N3 algorithm:
-- direct matrix-vector multiplication using a dense matrix.
--
--   N(3) =  0.7887   0.5774  -0.2113
--           0.5774  -0.5774   0.5774
--          -0.2113   0.5774   0.7887
--
-- The matrix coefficients were generated in Python using a direct
-- implementation of the DHT-IV transform:
--
--   C[k,n] = (1/sqrt(N)) * (cos(theta) + sin(theta))
--
-- where:
--
--   theta = pi*(2*k+1)*(2*n+1)/(2*N)
--
-- The coefficients were rounded to 4 decimal places and stored as
-- fixed-point constants.
--
-- No sparsity optimization is used: every matrix element contributes
-- to a real multiplication. This implementation serves as a baseline
-- for comparison with the proposed architecture.
--
-- Latency: 1 clock cycle (output register only).
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.fixed_types_pkg.all;

entity n3_naive is
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        valid_in  : in  std_logic;
        x         : in  sfix32_vector(0 to 2);
        valid_out : out std_logic;
        y         : out sfix32_vector(0 to 2)
    );
end entity n3_naive;

architecture rtl of n3_naive is

    -- N(3) matrix coefficients stored row by row
    constant N00 : sfix32 := to_sfixed( 0.7887, 15, -16);
    constant N01 : sfix32 := to_sfixed( 0.5774, 15, -16);
    constant N02 : sfix32 := to_sfixed(-0.2113, 15, -16);

    constant N10 : sfix32 := to_sfixed( 0.5774, 15, -16);
    constant N11 : sfix32 := to_sfixed(-0.5774, 15, -16);
    constant N12 : sfix32 := to_sfixed( 0.5774, 15, -16);

    constant N20 : sfix32 := to_sfixed(-0.2113, 15, -16);
    constant N21 : sfix32 := to_sfixed( 0.5774, 15, -16);
    constant N22 : sfix32 := to_sfixed( 0.7887, 15, -16);

    signal y_comb : sfix32_vector(0 to 2);

begin

    y_comb(0) <= resize32(N00 * x(0) + N01 * x(1) + N02 * x(2));
    y_comb(1) <= resize32(N10 * x(0) + N11 * x(1) + N12 * x(2));
    y_comb(2) <= resize32(N20 * x(0) + N21 * x(1) + N22 * x(2));

    process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                y         <= (others => (others => '0'));
                valid_out <= '0';
            else
                y         <= y_comb;
                valid_out <= valid_in;
            end if;
        end if;
    end process;

end architecture rtl;
