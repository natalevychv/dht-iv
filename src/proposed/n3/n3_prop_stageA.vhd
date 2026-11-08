-------------------------------------------------------------------------------
-- n3_prop_stageA.vhd
--
-- Stage A of the proposed 3-point DHT-IV architecture.
--
-- Forms the two input sums that are the operands of the 2 multiplications
-- performed in Stage B. This stage has no multipliers: the operands and
-- the input vector are registered and passed on.
--
-- Inputs:  x(0..2)      - input samples
-- Outputs: x_out(0..2)  - registered input samples
--          m(0..1)      - multiplier operands:
--                         m(0) = 2*x(1) + x(0) + x(2),
--                         m(1) = x(0) - x(1) + x(2)
--
-- Latency: 1 clock cycle (output register).
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.fixed_types_pkg.all;

entity n3_prop_stageA is
  port (
    clk       : in std_logic;
    rst       : in std_logic;
    valid_in  : in std_logic;
    x         : in sfix32_vector(0 to 2);
    valid_out : out std_logic;
    x_out     : out sfix32_vector(0 to 2);
    m         : out sfix32_vector(0 to 1)
  );
end entity n3_prop_stageA;

architecture rtl of n3_prop_stageA is
  signal m_int : sfix32_vector(0 to 1);
  signal sum0  : sfix32;
  signal sum1  : sfix32;
begin
  sum0 <= wrap32(shift_left(x(1), 1) + x(0) + x(2));
  sum1 <= wrap32(x(0) - x(1) + x(2));

  m_int(0) <= sum0;
  m_int(1) <= sum1;

  process (clk)
  begin
    if rising_edge(clk) then
      x_out     <= x;
      m         <= m_int;
      if rst = '1' then
        valid_out <= '0';
      else
        valid_out <= valid_in;
      end if;
    end if;
  end process;
end architecture rtl;
