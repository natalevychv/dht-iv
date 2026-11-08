-------------------------------------------------------------------------------
-- n5_prop_stageB.vhd
--
-- Stage B of the proposed 5-point DHT-IV architecture.
--
-- Computes the 6 coefficient multiplications (C_COEF_S_0_5, C_COEF_S_1_5,
-- C_COEF_S_3_5 .. C_COEF_S_6_5, passed as generics) and a scaling by 1/4
-- implemented as an arithmetic right shift (the shifted-out bits are
-- truncated). Multiplications only: the operands are formed in Stage A.
--
-- Inputs:  m_in(0..5)   - multiplier operands
-- Outputs: p_out(0..6)  - partial products:
--                         p(0) = C_COEF_S_0_5 * m(0),
--                         p(1) = C_COEF_S_1_5 * m(1),
--                         p(2) = m(2) / 4,
--                         p(3) = C_COEF_S_3_5 * m(1),
--                         p(4) = C_COEF_S_4_5 * m(3),
--                         p(5) = C_COEF_S_5_5 * m(4),
--                         p(6) = C_COEF_S_6_5 * m(5)
--
-- Latency: 1 clock cycle (output register).
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.fixed_types_pkg.all;

entity n5_prop_stageB is
  generic (
    C_COEF_S_0_5_G : sfix_coef;
    C_COEF_S_1_5_G : sfix_coef;
    C_COEF_S_3_5_G : sfix_coef;
    C_COEF_S_4_5_G : sfix_coef;
    C_COEF_S_5_5_G : sfix_coef;
    C_COEF_S_6_5_G : sfix_coef
  );
  port (
    clk       : in std_logic;
    rst       : in std_logic;
    valid_in  : in std_logic;
    m_in      : in sfix32_vector(0 to 5);
    valid_out : out std_logic;
    p_out     : out sfix32_vector(0 to 6)
  );
end entity n5_prop_stageB;

architecture rtl of n5_prop_stageB is
  signal p_int : sfix32_vector(0 to 6);
begin

  p_int(0) <= resize32(C_COEF_S_0_5_G * m_in(0));
  p_int(1) <= resize32(C_COEF_S_1_5_G * m_in(1));
  p_int(2) <= wrap32(shift_right(m_in(2), 2));
  p_int(3) <= resize32(C_COEF_S_3_5_G * m_in(1));
  p_int(4) <= resize32(C_COEF_S_4_5_G * m_in(3));
  p_int(5) <= resize32(C_COEF_S_5_5_G * m_in(4));
  p_int(6) <= resize32(C_COEF_S_6_5_G * m_in(5));

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
