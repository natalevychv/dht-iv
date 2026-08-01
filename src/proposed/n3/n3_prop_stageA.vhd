-------------------------------------------------------------------------------
-- n3_prop_stageA.vhd
--
--
--
--
--
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.fixed_types_pkg.all;

entity n3_prop_stageA is
  generic (
    C_COEF_S_0_3_G : sfix32;
    C_COEF_S_1_3_G : sfix32
  );
  port (
    clk       : in std_logic;
    rst       : in std_logic;
    valid_in  : in std_logic;
    x         : in sfix32_vector(0 to 2);
    valid_out : out std_logic;
    x_out     : out sfix32_vector(0 to 2);
    p_0       : out sfix32;
    y_1       : out sfix32
  );
end entity n3_prop_stageA;

architecture rtl of n3_prop_stageA is
  signal p_0_int : sfix32;
  signal y_1_int : sfix32;
  signal sum0    : sfix32;
  signal sum1    : sfix32;
begin
  sum0 <= resize32(shift_left(x(1), 1) + x(0) + x(2));
  sum1 <= resize32(x(0) - x(1) + x(2));

  p_0_int <= resize32(sum0 * C_COEF_S_0_3_G);
  y_1_int <= resize32(sum1 * C_COEF_S_1_3_G);

  process (clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        x_out     <= (others => (others => '0'));
        p_0       <= SFIX32_ZERO;
        y_1       <= SFIX32_ZERO;
        valid_out <= '0';
      else
        x_out     <= x;
        p_0       <= p_0_int;
        y_1       <= y_1_int;
        valid_out <= valid_in;
      end if;
    end if;
  end process;
end architecture rtl;
