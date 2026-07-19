-------------------------------------------------------------------------------
-- n3_prop_stage_M_3.vhd -- matrix3 (5x5), 5 -> 5
--   [1 0 1 0 1]   w0 = z0 + z2 + z4
--   [0 1 0 0 0]   w1 = z1
--   [0 0 1 0 0]   w2 = z2
--   [0 0 0 1 0]   w3 = z3
--   [0 0 0 0 1]   w4 = z4
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.fixed_types_pkg.all;

entity n3_prop_stage_M_3 is
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        valid_in  : in  std_logic;
        x         : in  sfix32_vector(0 to 4);
        valid_out : out std_logic;
        y         : out sfix32_vector(0 to 4)
    );
end entity n3_prop_stage_M_3;

architecture rtl of n3_prop_stage_M_3 is
    signal y_comb : sfix32_vector(0 to 4);
begin
    y_comb(0) <= resize32(x(0) + x(2) + x(4));
    y_comb(1) <= x(1);
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
