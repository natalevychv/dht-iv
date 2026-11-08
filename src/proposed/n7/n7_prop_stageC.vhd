-------------------------------------------------------------------------------
-- n7_prop_stageC.vhd
--
-- Stage C of the proposed 7-point DHT-IV architecture.
--
-- Combines partial products into intermediate sums; p(0) and p(1)
-- are passed through. No multiplications.
--
-- Inputs:  p_in(0..9)   - partial products
-- Outputs: p_out(0..7)  - intermediate sums
--
-- Latency: 1 clock cycle (output register).
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
  sum0 <= wrap32(p_in(3) + p_in(5));
  sum1 <= wrap32(p_in(4) + p_in(5));
  sum2 <= wrap32(p_in(7) + p_in(9));
  sum3 <= wrap32(p_in(8) + p_in(9));

  p_int(0) <= p_in(0);
  p_int(1) <= p_in(1);
  p_int(2) <= wrap32(p_in(2) + sum0 + sum1);
  p_int(3) <= wrap32(p_in(2) - sum0);
  p_int(4) <= wrap32(p_in(2) - sum1);
  p_int(5) <= wrap32(p_in(6) + sum2 + sum3);
  p_int(6) <= wrap32(p_in(6) - sum2);
  p_int(7) <= wrap32(p_in(6) - sum3);

  process (clk)
  begin
    if rising_edge(clk) then
      p_out     <= p_int;
      if rst = '1' then
        valid_out <= '0';
      else
        valid_out <= valid_in;
      end if;
    end if;
  end process;
end architecture rtl;
