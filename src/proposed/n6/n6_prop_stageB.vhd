-------------------------------------------------------------------------------
-- n6_prop_stageB.vhd
--
-- Stage B of the proposed 6-point DHT-IV architecture.
--
-- Computes 4 coefficient multiplications (C_COEF_S_1_6 .. C_COEF_S_4_6,
-- passed as generics) and 2 scalings by 1/4 implemented as arithmetic
-- right shifts (the shifted-out bits are truncated). Multiplications
-- only: the operands are formed in Stage A.
--
-- Inputs:  m_in(0..5)   - multiplier operands
-- Outputs: p_out(0..5)  - products and scaled sums:
--                         p(0) = m(0) / 4,
--                         p(k) = C_COEF_S_k_6 * m(k), k = 1..4,
--                         p(5) = m(5) / 4
--
-- Latency: 1 clock cycle (output register).
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.fixed_types_pkg.all;

entity n6_prop_stageB is
  generic (
    C_COEF_S_1_6_G : sfix_coef;
    C_COEF_S_2_6_G : sfix_coef;
    C_COEF_S_3_6_G : sfix_coef;
    C_COEF_S_4_6_G : sfix_coef
  );
  port (
    clk       : in std_logic;
    rst       : in std_logic;
    valid_in  : in std_logic;
    m_in      : in sfix32_vector(0 to 5);
    valid_out : out std_logic;
    p_out     : out sfix32_vector(0 to 5)
  );
end entity n6_prop_stageB;

architecture rtl of n6_prop_stageB is
  signal p_int : sfix32_vector(0 to 5);
begin

  p_int(0) <= wrap32(shift_right(m_in(0), 2));
  p_int(1) <= resize32(C_COEF_S_1_6_G * m_in(1));
  p_int(2) <= resize32(C_COEF_S_2_6_G * m_in(2));
  p_int(3) <= resize32(C_COEF_S_3_6_G * m_in(3));
  p_int(4) <= resize32(C_COEF_S_4_6_G * m_in(4));
  p_int(5) <= wrap32(shift_right(m_in(5), 2));

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
