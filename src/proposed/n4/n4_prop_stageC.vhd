-------------------------------------------------------------------------------
-- n4_prop_stageC.vhd
--
-- Stage C of the proposed 4-point DHT-IV architecture.
--
-- Adds pairs of partial products from Stage B and forms the final
-- transform outputs with the output butterflies. No multiplications.
--
-- Inputs:  p_in(0..5)  - partial products
-- Outputs: y(0..3)     - transform outputs
--
-- Latency: 1 clock cycle (output register).
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.fixed_types_pkg.all;

entity n4_prop_stageC is
  port (
    clk       : in std_logic;
    rst       : in std_logic;
    valid_in  : in std_logic;
    p_in      : in sfix32_vector(0 to 5);
    valid_out : out std_logic;
    y         : out sfix32_vector(0 to 3)
  );
end entity n4_prop_stageC;

architecture rtl of n4_prop_stageC is
  signal q     : sfix32_vector(0 to 3);
  signal y_int : sfix32_vector(0 to 3);
begin

  -- Intermediate sums
  q(0) <= wrap32(p_in(0) + p_in(2));
  q(1) <= wrap32(p_in(1) + p_in(2));
  q(2) <= wrap32(p_in(3) + p_in(5));
  q(3) <= wrap32(p_in(4) + p_in(5));

  -- Output butterflies
  y_int(0) <= wrap32(q(0) + q(2));
  y_int(1) <= wrap32(q(0) - q(2));
  y_int(2) <= wrap32(q(1) + q(3));
  y_int(3) <= wrap32(q(3) - q(1));

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
