-------------------------------------------------------------------------------
-- n3_prop_stage_M_2.vhd -- matrix2 (5x5), 5 -> 5
--   [a 0 0 0 0]   v0 = w0 * a
--   [0 b 0 0 0]   v1 = w1 * b
--   [0 0 1 0 0]   v2 = w2
--   [0 0 0 1 0]   v3 = w3
--   [0 0 0 0 1]   v4 = w4
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.fixed_types_pkg.all;

entity n3_prop_stage_M_2 is
    generic (
        COEF_A_G : sfix32;
        COEF_B_G : sfix32
    );
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        valid_in  : in  std_logic;
        x         : in  sfix32_vector(0 to 4);
        valid_out : out std_logic;
        y         : out sfix32_vector(0 to 4)
    );
end entity n3_prop_stage_M_2;

architecture rtl of n3_prop_stage_M_2 is
    signal y_comb : sfix32_vector(0 to 4);
begin
    y_comb(0) <= resize32(COEF_A_G * x(0));
    y_comb(1) <= resize32(COEF_B_G * x(1));
    y_comb(2) <= x(2);
    y_comb(3) <= x(3);
    y_comb(4) <= x(4);

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
