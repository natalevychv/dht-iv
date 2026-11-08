-------------------------------------------------------------------------------
-- n7_prop_stageB.vhd
--
-- Stage B of the proposed 7-point DHT-IV architecture.
--
-- Computes the 10 coefficient multiplications
-- p_out(k) = C_COEF_S_k_7 * m_in(k), k = 0..9 (coefficients passed as
-- generics). Multiplications only: the operands are formed in Stage A.
--
-- Inputs:  m_in(0..9)   - multiplier operands
-- Outputs: p_out(0..9)  - partial products
--
-- Latency: 1 clock cycle (output register).
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.fixed_types_pkg.all;

entity n7_prop_stageB is
  generic (
    C_COEF_S_0_7_G : sfix_coef;
    C_COEF_S_1_7_G : sfix_coef;
    C_COEF_S_2_7_G : sfix_coef;
    C_COEF_S_3_7_G : sfix_coef;
    C_COEF_S_4_7_G : sfix_coef;
    C_COEF_S_5_7_G : sfix_coef;
    C_COEF_S_6_7_G : sfix_coef;
    C_COEF_S_7_7_G : sfix_coef;
    C_COEF_S_8_7_G : sfix_coef;
    C_COEF_S_9_7_G : sfix_coef
  );
  port (
    clk       : in std_logic;
    rst       : in std_logic;
    valid_in  : in std_logic;
    m_in      : in sfix32_vector(0 to 9);
    valid_out : out std_logic;
    p_out     : out sfix32_vector(0 to 9)
  );
end entity n7_prop_stageB;

architecture rtl of n7_prop_stageB is
  signal p_int : sfix32_vector(0 to 9);
begin

  p_int(0) <= resize32(C_COEF_S_0_7_G * m_in(0));
  p_int(1) <= resize32(C_COEF_S_1_7_G * m_in(1));
  p_int(2) <= resize32(C_COEF_S_2_7_G * m_in(2));
  p_int(3) <= resize32(C_COEF_S_3_7_G * m_in(3));
  p_int(4) <= resize32(C_COEF_S_4_7_G * m_in(4));
  p_int(5) <= resize32(C_COEF_S_5_7_G * m_in(5));
  p_int(6) <= resize32(C_COEF_S_6_7_G * m_in(6));
  p_int(7) <= resize32(C_COEF_S_7_7_G * m_in(7));
  p_int(8) <= resize32(C_COEF_S_8_7_G * m_in(8));
  p_int(9) <= resize32(C_COEF_S_9_7_G * m_in(9));

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
