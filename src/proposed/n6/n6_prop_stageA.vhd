-------------------------------------------------------------------------------
-- n6_prop_stageA.vhd
--
-- Stage A of the proposed 6-point DHT-IV architecture.
--
-- Input butterflies b(0..5) (sums and differences of x(i) and x(i+3))
-- followed by the pre-addition sums that form the operands of the 4
-- multiplications and 2 scalings performed in Stage B. This stage has no
-- multipliers: only the operands are registered.
--
-- Inputs:  x(0..5)  - input samples
-- Outputs: m(0..5)  - multiplier operands:
--                     m(0) = b(0) + b(2), m(1) = b(1),
--                     m(2) = b(0) - b(2), m(3) = b(3) - b(5),
--                     m(4) = b(4),        m(5) = b(5) + b(3)
--
-- Latency: 1 clock cycle (output register).
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.fixed_types_pkg.all;

entity n6_prop_stageA is
  port (
    clk       : in std_logic;
    rst       : in std_logic;
    valid_in  : in std_logic;
    x         : in sfix32_vector(0 to 5);
    valid_out : out std_logic;
    m         : out sfix32_vector(0 to 5)
  );
end entity n6_prop_stageA;

architecture rtl of n6_prop_stageA is
  signal b     : sfix32_vector(0 to 5);
  signal m_int : sfix32_vector(0 to 5);
  signal sum0  : sfix32;
  signal sum1  : sfix32;
  signal sum2  : sfix32;
  signal sum3  : sfix32;
begin

  -- Input butterflies
  b(0) <= wrap32(x(0) + x(3));
  b(1) <= wrap32(x(1) - x(4));
  b(2) <= wrap32(x(2) + x(5));
  b(3) <= wrap32(x(0) - x(3));
  b(4) <= wrap32(x(1) + x(4));
  b(5) <= wrap32(x(2) - x(5));

  -- Pre-addition sums
  sum0 <= wrap32(b(0) + b(2));
  sum1 <= wrap32(b(0) - b(2));
  sum2 <= wrap32(b(3) - b(5));
  sum3 <= wrap32(b(5) + b(3));

  -- Multiplier operands
  m_int(0) <= sum0;
  m_int(1) <= b(1);
  m_int(2) <= sum1;
  m_int(3) <= sum2;
  m_int(4) <= b(4);
  m_int(5) <= sum3;

  process (clk)
  begin
    if rising_edge(clk) then
      m         <= m_int;
      if rst = '1' then
        valid_out <= '0';
      else
        valid_out <= valid_in;
      end if;
    end if;
  end process;
end architecture rtl;
