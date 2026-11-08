-------------------------------------------------------------------------------
-- n8_prop_stageA.vhd
--
-- Stage A of the proposed 8-point DHT-IV architecture.
--
-- Input butterflies p(0..7) on the pairs (x0,x3), (x1,x2), (x4,x7),
-- (x5,x6), followed by the pre-addition sums that form the operands of
-- the 18 multiplications performed in Stage B. This stage has no
-- multipliers: only the operands are registered.
--
-- Inputs:  x(0..7)   - input samples
-- Outputs: m(0..17)  - multiplier operands. For each half h = 0, 1 with
--                      q(i) = p(4h + i):
--                      m(9h+0) = q(0),        m(9h+1) = q(1),
--                      m(9h+2) = q(1) + q(0), m(9h+3) = q(2),
--                      m(9h+4) = q(3),        m(9h+5) = q(3) + q(2),
--                      m(9h+6) = q(0) + q(2), m(9h+7) = q(1) + q(3),
--                      m(9h+8) = m(9h+7) + m(9h+6)
--
-- Latency: 1 clock cycle (output register).
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.fixed_types_pkg.all;

entity n8_prop_stageA is
  port (
    clk       : in std_logic;
    rst       : in std_logic;
    valid_in  : in std_logic;
    x         : in sfix32_vector(0 to 7);
    valid_out : out std_logic;
    m         : out sfix32_vector(0 to 17)
  );
end entity n8_prop_stageA;

architecture rtl of n8_prop_stageA is
  signal p     : sfix32_vector(0 to 7);
  signal m_int : sfix32_vector(0 to 17);
begin

  -- Input butterflies
  p(0) <= wrap32(x(7) - x(4));
  p(1) <= wrap32(x(5) - x(6));
  p(2) <= wrap32(x(0) + x(3));
  p(3) <= wrap32(x(1) + x(2));
  p(4) <= wrap32(x(7) + x(4));
  p(5) <= wrap32(x(6) + x(5));
  p(6) <= wrap32(x(0) - x(3));
  p(7) <= wrap32(-x(1) + x(2));

  -- Multiplier operands, first half (from p(0..3))
  m_int(0) <= p(0);
  m_int(1) <= p(1);
  m_int(2) <= wrap32(p(1) + p(0));
  m_int(3) <= p(2);
  m_int(4) <= p(3);
  m_int(5) <= wrap32(p(3) + p(2));
  m_int(6) <= wrap32(p(0) + p(2));
  m_int(7) <= wrap32(p(1) + p(3));
  m_int(8) <= wrap32(m_int(7) + m_int(6));

  -- Multiplier operands, second half (from p(4..7))
  m_int(9)  <= p(4);
  m_int(10) <= p(5);
  m_int(11) <= wrap32(p(5) + p(4));
  m_int(12) <= p(6);
  m_int(13) <= p(7);
  m_int(14) <= wrap32(p(7) + p(6));
  m_int(15) <= wrap32(p(4) + p(6));
  m_int(16) <= wrap32(p(5) + p(7));
  m_int(17) <= wrap32(m_int(16) + m_int(15));

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
