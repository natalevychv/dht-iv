-------------------------------------------------------------------------------
-- n3_prop_stageB.vhd
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.fixed_types_pkg.all;

entity n3_prop_stageB is
  port (
    clk       : in std_logic;
    rst       : in std_logic;
    valid_in  : in std_logic;
    x         : in sfix32_vector(0 to 2);
    p_0       : in sfix32;
    y_1       : in sfix32;
    valid_out : out std_logic;
    y         : out sfix32_vector(0 to 2)
  );
end entity n3_prop_stageB;

architecture rtl of n3_prop_stageB is
  signal y_int : sfix32_vector(0 to 2);
  signal p_1   : sfix32;
begin

  p_1 <= resize32(x(1) + p_0);

  y_int(0) <= resize32(x(0) + p_1);
  y_int(1) <= y_1;
  y_int(2) <= resize32(x(2) + p_1);

  process (clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        y         <= (others => (others => '0'));
        valid_out <= '0';
      else
        y         <= y_int;
        valid_out <= valid_in;
      end if;
    end if;
  end process;
end architecture rtl;
