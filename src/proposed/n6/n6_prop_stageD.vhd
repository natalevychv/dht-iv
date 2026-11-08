-------------------------------------------------------------------------------
-- n6_prop_stageD.vhd
--
-- Stage D of the proposed 6-point DHT-IV architecture.
--
-- Output butterflies forming the final transform outputs.
-- No multiplications.
--
-- Inputs:  p_in(0..5)  - intermediate sums
-- Outputs: y(0..5)     - transform outputs
--
-- Latency: 1 clock cycle (output register).
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.fixed_types_pkg.all;

entity n6_prop_stageD is
  port (
    clk       : in std_logic;
    rst       : in std_logic;
    valid_in  : in std_logic;
    p_in      : in sfix32_vector(0 to 5);
    valid_out : out std_logic;
    y         : out sfix32_vector(0 to 5)
  );
end entity n6_prop_stageD;

architecture rtl of n6_prop_stageD is
  signal y_int : sfix32_vector(0 to 5);
begin

  y_int(0) <= wrap32(p_in(0) + p_in(3));
  y_int(1) <= wrap32(p_in(1) + p_in(4));
  y_int(2) <= wrap32(p_in(2) + p_in(5));
  y_int(3) <= wrap32(p_in(0) - p_in(3));
  y_int(4) <= wrap32(p_in(4) - p_in(1));
  y_int(5) <= wrap32(p_in(2) - p_in(5));

  process (clk)
  begin
    if rising_edge(clk) then
      y         <= y_int;
      if rst = '1' then
        valid_out <= '0';
      else
        valid_out <= valid_in;
      end if;
    end if;
  end process;
end architecture rtl;
