-------------------------------------------------------------------------------
-- n3_prop_stage_M_1.vhd -- matrix1 (4x5), 5 -> 4
--   [1 0 0 1 0]   u0 = v0 + v3
--   [0 0 1 0 0]   u1 = v2
--   [0 1 0 0 0]   u2 = v1
--   [0 0 0 0 1]   u3 = v4
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.fixed_types_pkg.all;

entity n3_prop_stage_M_1 is
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        valid_in  : in  std_logic;
        x         : in  sfix32_vector(0 to 4);
        valid_out : out std_logic;
        y         : out sfix32_vector(0 to 3)
    );
end entity n3_prop_stage_M_1;

architecture rtl of n3_prop_stage_M_1 is
    signal y_comb : sfix32_vector(0 to 3);
begin
    y_comb(0) <= resize32(x(0) + x(3));
    y_comb(1) <= x(2);
    y_comb(2) <= x(1);
    y_comb(3) <= x(4);

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
