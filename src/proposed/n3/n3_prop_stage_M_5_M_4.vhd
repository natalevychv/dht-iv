-------------------------------------------------------------------------------
-- n3_prop_stage_M_5_M_4.vhd  -- matrix5 (5x3) + matrix4(5x5), input 3-vector -> output 5-vector
--   [0  1  0]      z0 = x1 * 2
--   [1 -1  1]      z1 = x0 - x1 + x2
--   [1  0  0]      z2 = x0
--   [0  1  0]      z3 = x1
--   [0  0  1]      z4 = x2
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.fixed_types_pkg.all;

entity n3_prop_stage_M_5_M_4 is
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        valid_in  : in  std_logic;
        x         : in  sfix32_vector(0 to 2);
        valid_out : out std_logic;
        y         : out sfix32_vector(0 to 4)
    );
end entity n3_prop_stage_M_5_M_4;

architecture rtl of n3_prop_stage_M_5_M_4 is
    signal y_comb : sfix32_vector(0 to 4);
begin
    y_comb(0) <= shift_left(x(1), 1);
    y_comb(1) <= resize32(resize32(x(0) - x(1)) + x(2));
    y_comb(2) <= x(0);
    y_comb(3) <= x(1);
    y_comb(4) <= x(2);

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
