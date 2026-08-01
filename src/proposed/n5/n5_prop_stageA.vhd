-------------------------------------------------------------------------------
-- n5_prop_stageA.vhd
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

entity n5_prop_stageA is
  generic (
    C_COEF_S_0_5_G : sfix32;
    C_COEF_S_1_5_G : sfix32;
    C_COEF_S_2_5_G : sfix32;
    C_COEF_S_3_5_G : sfix32;
    C_COEF_S_4_5_G : sfix32;
    C_COEF_S_5_5_G : sfix32;
    C_COEF_S_6_5_G : sfix32
  );
  port (
    clk       : in std_logic;
    rst       : in std_logic;
    valid_in  : in std_logic;
    x         : in sfix32_vector(0 to 4);
    valid_out : out std_logic;
    p         : out sfix32_vector(0 to 6)
  );
end entity n5_prop_stageA;

architecture rtl of n5_prop_stageA is
  signal p_int   : sfix32_vector(0 to 6);
  signal sum0    : sfix32;
  signal sum1    : sfix32;
  signal sum0_1  : sfix32;
  signal sum0_n1 : sfix32;
  signal sum4    : sfix32;
  signal sum5    : sfix32;
  signal sum4_5  : sfix32;
begin
  sum0    <= resize32(x(0) + x(4));
  sum1    <= resize32(x(1) + x(3));
  sum0_1  <= resize32(sum0 + sum1);
  sum0_n1 <= resize32(sum0 - sum1);
  sum4    <= resize32(x(0) - x(4));
  sum5    <= resize32(x(1) - x(3));
  sum4_5  <= resize32(sum4 + sum5);

  p_int(0) <= resize32(C_COEF_S_0_5_G * sum0_1);
  p_int(1) <= resize32(C_COEF_S_1_5_G * sum0_n1);
  p_int(2) <= resize32(C_COEF_S_2_5_G * x(2));
  p_int(3) <= resize32(C_COEF_S_3_5_G * sum0_n1);
  p_int(4) <= resize32(C_COEF_S_4_5_G * sum4);
  p_int(5) <= resize32(C_COEF_S_5_5_G * sum5);
  p_int(6) <= resize32(C_COEF_S_6_5_G * sum4_5);

  process (clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        p         <= (others => (others => '0'));
        valid_out <= '0';
      else
        p         <= p_int;
        valid_out <= valid_in;
      end if;
    end if;
  end process;
end architecture rtl;
