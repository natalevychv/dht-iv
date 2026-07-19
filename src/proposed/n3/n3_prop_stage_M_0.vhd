-------------------------------------------------------------------------------
-- n3_prop_stage_M_0.vhd -- matrix0 (3x4), 4 -> 3 (final stage)
--   [1 1 0 0]   r0 = u0 + u1
--   [0 0 1 0]   r1 = u2
--   [1 0 0 1]   r2 = u0 + u3
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.fixed_types_pkg.all;

entity n3_prop_stage_M_0 is
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        valid_in  : in  std_logic;
        x         : in  sfix32_vector(0 to 3);
        valid_out : out std_logic;
        y         : out sfix32_vector(0 to 2)
    );
end entity n3_prop_stage_M_0;

architecture rtl of n3_prop_stage_M_0 is
    signal y_comb : sfix32_vector(0 to 2);
begin
    y_comb(0) <= resize32(x(0) + x(1));
    y_comb(1) <= x(2);
    y_comb(2) <= resize32(x(0) + x(3));

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
