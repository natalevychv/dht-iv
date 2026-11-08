-------------------------------------------------------------------------------
-- n5_prop_stageA.vhd
--
-- Stage A of the proposed 5-point DHT-IV architecture.
--
-- Input butterflies forming the operands of the 6 multiplications and
-- the scaling by 1/4 performed in Stage B. This stage has no multipliers:
-- only the operands are registered.
--
-- Inputs:  x(0..4)  - input samples
-- Outputs: m(0..5)  - multiplier operands:
--                     m(0) = x(2),
--                     m(1) = (x(0) + x(4)) - (x(1) + x(3)),
--                     m(2) = (x(0) + x(4)) + (x(1) + x(3)),
--                     m(3) = x(0) - x(4),
--                     m(4) = x(1) - x(3),
--                     m(5) = m(3) + m(4)
--
-- Latency: 1 clock cycle (output register).
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.fixed_types_pkg.all;

entity n5_prop_stageA is
  port (
    clk       : in std_logic;
    rst       : in std_logic;
    valid_in  : in std_logic;
    x         : in sfix32_vector(0 to 4);
    valid_out : out std_logic;
    m         : out sfix32_vector(0 to 5)
  );
end entity n5_prop_stageA;

architecture rtl of n5_prop_stageA is
  signal m_int   : sfix32_vector(0 to 5);
  signal sum0    : sfix32;
  signal sum1    : sfix32;
  signal sum0_1  : sfix32;
  signal sum0_n1 : sfix32;
  signal sum4    : sfix32;
  signal sum5    : sfix32;
  signal sum4_5  : sfix32;
begin
  sum0    <= wrap32(x(0) + x(4));
  sum1    <= wrap32(x(1) + x(3));
  sum0_1  <= wrap32(sum0 + sum1);
  sum0_n1 <= wrap32(sum0 - sum1);
  sum4    <= wrap32(x(0) - x(4));
  sum5    <= wrap32(x(1) - x(3));
  sum4_5  <= wrap32(sum4 + sum5);

  m_int(0) <= x(2);
  m_int(1) <= sum0_n1;
  m_int(2) <= sum0_1;
  m_int(3) <= sum4;
  m_int(4) <= sum5;
  m_int(5) <= sum4_5;

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
