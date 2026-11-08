-------------------------------------------------------------------------------
-- n5_prop_stageC.vhd
--
-- Stage C of the proposed 5-point DHT-IV architecture.
--
-- Combines the partial products from Stage B into intermediate sums and
-- forms the final transform outputs with the output butterflies.
-- No multiplications.
--
-- Inputs:  p_in(0..6)  - partial products
-- Outputs: y(0..4)     - transform outputs
--
-- Latency: 1 clock cycle (output register).
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.fixed_types_pkg.all;

entity n5_prop_stageC is
  port (
    clk       : in std_logic;
    rst       : in std_logic;
    valid_in  : in std_logic;
    p_in      : in sfix32_vector(0 to 6);
    valid_out : out std_logic;
    y         : out sfix32_vector(0 to 4)
  );
end entity n5_prop_stageC;

architecture rtl of n5_prop_stageC is
  signal y_int   : sfix32_vector(0 to 4);
  signal sum2_3  : sfix32;
  signal sum2_n3 : sfix32;
  signal sum4_6  : sfix32;
  signal sum5_6  : sfix32;
  signal q2      : sfix32;
  signal q3      : sfix32;
  signal q4      : sfix32;
  signal q5      : sfix32;
begin

  -- Intermediate sums
  sum2_3  <= wrap32(p_in(2) + p_in(3));
  sum2_n3 <= wrap32(p_in(2) - p_in(3));
  sum4_6  <= wrap32(p_in(4) + p_in(6));
  sum5_6  <= wrap32(p_in(5) + p_in(6));

  q2 <= wrap32(sum2_3 + sum4_6);
  q3 <= wrap32(sum2_n3 + sum5_6);
  q4 <= wrap32(sum2_3 - sum4_6);
  q5 <= wrap32(sum2_n3 - sum5_6);

  -- Output butterflies
  y_int(0) <= wrap32(q2 + p_in(0));
  y_int(1) <= wrap32(q3 - p_in(0));
  y_int(2) <= wrap32(p_in(1) + p_in(0));
  y_int(3) <= wrap32(q5 - p_in(0));
  y_int(4) <= wrap32(q4 + p_in(0));

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
