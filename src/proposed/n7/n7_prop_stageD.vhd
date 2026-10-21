-------------------------------------------------------------------------------
-- n7_prop_stageD.vhd
--
-- Stage D of the proposed 7-point DHT-IV architecture.
--
-- Output butterflies forming the final transform outputs;
-- y(3) is taken directly from p(0). No multiplications.
--
-- Inputs:  p_in(0..7)  - intermediate sums
-- Outputs: y(0..6)     - transform outputs
--
-- Latency: 1 clock cycle (output register).
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.fixed_types_pkg.all;

entity n7_prop_stageD is
  port (
    clk       : in std_logic;
    rst       : in std_logic;
    valid_in  : in std_logic;
    p_in      : in sfix32_vector(0 to 7);
    valid_out : out std_logic;
    y         : out sfix32_vector(0 to 6)
  );
end entity n7_prop_stageD;

architecture rtl of n7_prop_stageD is
  signal y_int : sfix32_vector(0 to 6);
begin

  y_int(0) <= resize32(p_in(2) + p_in(5));
  y_int(1) <= resize32(p_in(6) + p_in(3) - p_in(1));
  y_int(2) <= resize32(p_in(4) - p_in(7));
  y_int(3) <= p_in(0);
  y_int(4) <= resize32(p_in(4) + p_in(7));
  y_int(5) <= resize32(-p_in(3) - p_in(6) - p_in(1));
  y_int(6) <= resize32(p_in(2) - p_in(5));

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
