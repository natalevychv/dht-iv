-------------------------------------------------------------------------------
-- n7_prop_stageC.vhd
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

entity n7_prop_stageC is
  port (
    clk       : in std_logic;
    rst       : in std_logic;
    valid_in  : in std_logic;
    p_in      : in sfix32_vector(0 to 9);
    valid_out : out std_logic;
    p_out     : out sfix32_vector(0 to 7)
  );
end entity n7_prop_stageC;

architecture rtl of n7_prop_stageC is
  signal p_int : sfix32_vector(0 to 7);
  signal sum0  : sfix32;
  signal sum1  : sfix32;
  signal sum2  : sfix32;
  signal sum3  : sfix32;

begin
  sum0 <= resize32(p_in(3) + p_in(5));
  sum1 <= resize32(p_in(4) + p_in(5));
  sum2 <= resize32(p_in(7) + p_in(9));
  sum3 <= resize32(p_in(8) + p_in(9));

  p_int(0) <= p_in(0);
  p_int(1) <= p_in(1);
  p_int(2) <= resize32(p_in(1) + p_in(2) + sum0 + sum1);
  p_int(3) <= resize32(p_in(2) + sum0);
  p_int(4) <= resize32(p_in(1) + p_in(2) - sum1);
  p_int(5) <= resize32(p_in(6) + sum2 + sum3);
  p_int(6) <= resize32(p_in(6) - sum2);
  p_int(7) <= resize32(p_in(6) - sum3);

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
