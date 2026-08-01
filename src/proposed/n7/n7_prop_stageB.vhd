-------------------------------------------------------------------------------
-- n7_prop_stageB.vhd
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

entity n7_prop_stageB is
  generic (
    C_COEF_S_0_7_G : sfix32;
    C_COEF_S_1_7_G : sfix32;
    C_COEF_S_2_7_G : sfix32;
    C_COEF_S_3_7_G : sfix32;
    C_COEF_S_4_7_G : sfix32;
    C_COEF_S_5_7_G : sfix32;
    C_COEF_S_6_7_G : sfix32;
    C_COEF_S_7_7_G : sfix32;
    C_COEF_S_8_7_G : sfix32;
    C_COEF_S_9_7_G : sfix32
  );
  port (
    clk       : in std_logic;
    rst       : in std_logic;
    valid_in  : in std_logic;
    p_in      : in sfix32_vector(0 to 7);
    valid_out : out std_logic;
    p_out     : out sfix32_vector(0 to 9)
  );
end entity n7_prop_stageB;

architecture rtl of n7_prop_stageB is
  signal p_int  : sfix32_vector(0 to 9);
  signal sum2   : sfix32;
  signal sum3   : sfix32;
  signal sum4   : sfix32;
  signal sum3_4 : sfix32;
  signal sum6   : sfix32;
  signal sum7   : sfix32;
  signal sum8   : sfix32;
  signal sum7_8 : sfix32;

begin
  sum2   <= resize32(p_in(2) + p_in(3) + p_in(4));
  sum3   <= resize32(p_in(2) - p_in(4));
  sum4   <= resize32(p_in(2) - p_in(3));
  sum3_4 <= resize32(sum3 + sum4);
  sum6   <= resize32(p_in(5) - p_in(6) + p_in(7));
  sum7   <= resize32(p_in(5) - p_in(7));
  sum8   <= resize32(p_in(5) + p_in(6));
  sum7_8 <= resize32(sum7 + sum8);

  p_int(0) <= resize32(C_COEF_S_0_7_G * p_in(0));
  p_int(1) <= resize32(C_COEF_S_1_7_G * p_in(1));
  p_int(2) <= resize32(C_COEF_S_2_7_G * sum2);
  p_int(3) <= resize32(C_COEF_S_3_7_G * sum3);
  p_int(4) <= resize32(C_COEF_S_4_7_G * sum4);
  p_int(5) <= resize32(C_COEF_S_5_7_G * sum3_4);
  p_int(6) <= resize32(C_COEF_S_6_7_G * sum6);
  p_int(7) <= resize32(C_COEF_S_7_7_G * sum7);
  p_int(8) <= resize32(C_COEF_S_8_7_G * sum8);
  p_int(9) <= resize32(C_COEF_S_9_7_G * sum7_8);
  process (clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        p_out     <= (others => (others => '0'));
        valid_out <= '0';
      else
        p_out     <= p_int;
        valid_out <= valid_in;
      end if;
    end if;
  end process;
end architecture rtl;
