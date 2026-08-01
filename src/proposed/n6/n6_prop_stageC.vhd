-------------------------------------------------------------------------------
-- n6_prop_stageC.vhd
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

entity n6_prop_stageC is
  port (
    clk       : in std_logic;
    rst       : in std_logic;
    valid_in  : in std_logic;
    p_in      : in sfix32_vector(0 to 5);
    valid_out : out std_logic;
    p_out     : out sfix32_vector(0 to 5)
  );
end entity n6_prop_stageC;

architecture rtl of n6_prop_stageC is
  signal p_int : sfix32_vector(0 to 5);
begin

  p_int(0) <= resize32(shift_right(p_in(0), 1) + p_in(1) + p_in(4));
  p_int(1) <= resize32(p_in(0) - p_in(1));
  p_int(2) <= resize32(-shift_right(p_in(2), 1) - p_in(1) + p_in(2));
  p_int(3) <= resize32(p_in(3) + p_in(4) + shift_right(p_in(5), 1));
  p_int(4) <= resize32(p_in(4) - p_in(5));
  p_int(5) <= resize32(p_in(3) - p_in(4) - shift_right(p_in(5), 1));

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
