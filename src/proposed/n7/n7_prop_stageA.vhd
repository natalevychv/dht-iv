-------------------------------------------------------------------------------
-- n7_prop_stageA.vhd
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

entity n7_prop_stageA is
  port (
    clk       : in std_logic;
    rst       : in std_logic;
    valid_in  : in std_logic;
    x         : in sfix32_vector(0 to 6);
    valid_out : out std_logic;
    p         : out sfix32_vector(0 to 7)
  );
end entity n7_prop_stageA;

architecture rtl of n7_prop_stageA is
  signal p_int : sfix32_vector(0 to 7);
begin

  p_int(0) <= resize32(x(0) - x(1) + x(2) + x(4) - x(3) + x(6) - x(5));
  p_int(1) <= x(3);
  p_int(2) <= resize32(x(2) + x(4));
  p_int(3) <= resize32(-x(1) - x(5));
  p_int(4) <= resize32(x(0) + x(6));
  p_int(5) <= resize32(x(2) - x(4));
  p_int(6) <= resize32(x(1) - x(5));
  p_int(7) <= resize32(x(6) - x(0));

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
