-------------------------------------------------------------------------------
-- n7_prop_stageA.vhd
--
-- Stage A of the proposed 7-point DHT-IV architecture.
--
-- Input butterflies p(0..7) (x(3) is passed through) followed by the
-- pre-addition sums that form the operands of the 10 multiplications
-- performed in Stage B. This stage has no multipliers: only the operands
-- are registered.
--
-- Inputs:  x(0..6)  - input samples
-- Outputs: m(0..9)  - multiplier operands:
--                     m(0) = p(0), m(1) = p(1),
--                     m(2) = p(2) + p(3) + p(4), m(3) = p(2) - p(4),
--                     m(4) = p(2) - p(3),        m(5) = m(3) + m(4),
--                     m(6) = p(5) - p(6) + p(7), m(7) = p(5) - p(7),
--                     m(8) = p(5) + p(6),        m(9) = m(7) + m(8)
--
-- Latency: 1 clock cycle (output register).
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.fixed_types_pkg.all;

entity n7_prop_stageA is
  port (
    clk       : in std_logic;
    rst       : in std_logic;
    valid_in  : in std_logic;
    x         : in sfix32_vector(0 to 6);
    valid_out : out std_logic;
    m         : out sfix32_vector(0 to 9)
  );
end entity n7_prop_stageA;

architecture rtl of n7_prop_stageA is
  signal p      : sfix32_vector(0 to 7);
  signal m_int  : sfix32_vector(0 to 9);
  signal sum2   : sfix32;
  signal sum3   : sfix32;
  signal sum4   : sfix32;
  signal sum3_4 : sfix32;
  signal sum6   : sfix32;
  signal sum7   : sfix32;
  signal sum8   : sfix32;
  signal sum7_8 : sfix32;
begin

  -- Input butterflies
  p(0) <= x(3);
  p(1) <= wrap32(((x(0) - x(1)) + (x(2) - x(5))) + (x(4) + x(6)));
  p(2) <= wrap32(x(2) + x(4));
  p(3) <= wrap32(-x(1) - x(5));
  p(4) <= wrap32(x(0) + x(6));
  p(5) <= wrap32(x(2) - x(4));
  p(6) <= wrap32(x(1) - x(5));
  p(7) <= wrap32(x(6) - x(0));

  -- Pre-addition sums
  sum2   <= wrap32(p(2) + p(3) + p(4));
  sum3   <= wrap32(p(2) - p(4));
  sum4   <= wrap32(p(2) - p(3));
  sum3_4 <= wrap32(sum3 + sum4);
  sum6   <= wrap32(p(5) - p(6) + p(7));
  sum7   <= wrap32(p(5) - p(7));
  sum8   <= wrap32(p(5) + p(6));
  sum7_8 <= wrap32(sum7 + sum8);

  -- Multiplier operands
  m_int(0) <= p(0);
  m_int(1) <= p(1);
  m_int(2) <= sum2;
  m_int(3) <= sum3;
  m_int(4) <= sum4;
  m_int(5) <= sum3_4;
  m_int(6) <= sum6;
  m_int(7) <= sum7;
  m_int(8) <= sum8;
  m_int(9) <= sum7_8;

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
