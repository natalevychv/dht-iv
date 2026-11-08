-------------------------------------------------------------------------------
-- n4_prop_stageB.vhd
--
-- Stage B of the proposed 4-point DHT-IV architecture.
--
-- Computes the 6 coefficient multiplications
-- p_out(k) = C_COEF_S_k_4 * m_in(k), k = 0..5 (coefficients passed as
-- generics). Multiplications only: the operands are formed in Stage A.
--
-- Inputs:  m_in(0..5)   - multiplier operands
-- Outputs: p_out(0..5)  - partial products
--
-- Latency: 1 clock cycle (output register).
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.fixed_types_pkg.all;

entity n4_prop_stageB is
  generic (
    C_COEF_S_0_4_G : sfix_coef;
    C_COEF_S_1_4_G : sfix_coef;
    C_COEF_S_2_4_G : sfix_coef;
    C_COEF_S_3_4_G : sfix_coef;
    C_COEF_S_4_4_G : sfix_coef;
    C_COEF_S_5_4_G : sfix_coef
  );
  port (
    clk       : in std_logic;
    rst       : in std_logic;
    valid_in  : in std_logic;
    m_in      : in sfix32_vector(0 to 5);
    valid_out : out std_logic;
    p_out     : out sfix32_vector(0 to 5)
  );
end entity n4_prop_stageB;

architecture rtl of n4_prop_stageB is
  signal p_int : sfix32_vector(0 to 5);
begin

  p_int(0) <= resize32(C_COEF_S_0_4_G * m_in(0));
  p_int(1) <= resize32(C_COEF_S_1_4_G * m_in(1));
  p_int(2) <= resize32(C_COEF_S_2_4_G * m_in(2));
  p_int(3) <= resize32(C_COEF_S_3_4_G * m_in(3));
  p_int(4) <= resize32(C_COEF_S_4_4_G * m_in(4));
  p_int(5) <= resize32(C_COEF_S_5_4_G * m_in(5));

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
