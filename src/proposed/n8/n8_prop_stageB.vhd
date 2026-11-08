-------------------------------------------------------------------------------
-- n8_prop_stageB.vhd
--
-- Stage B of the proposed 8-point DHT-IV architecture.
--
-- Computes all 18 coefficient multiplications
-- v_out(k) = C_COEF_S_k_8 * m_in(k), k = 0..17 (coefficients passed as
-- generics). Multiplications only: the operands are formed in Stage A.
--
-- Inputs:  m_in(0..17)   - multiplier operands
-- Outputs: v_out(0..17)  - products
--
-- Latency: 1 clock cycle (output register).
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.fixed_types_pkg.all;

entity n8_prop_stageB is
  generic (
    C_COEF_S_0_8_G  : sfix_coef;
    C_COEF_S_1_8_G  : sfix_coef;
    C_COEF_S_2_8_G  : sfix_coef;
    C_COEF_S_3_8_G  : sfix_coef;
    C_COEF_S_4_8_G  : sfix_coef;
    C_COEF_S_5_8_G  : sfix_coef;
    C_COEF_S_6_8_G  : sfix_coef;
    C_COEF_S_7_8_G  : sfix_coef;
    C_COEF_S_8_8_G  : sfix_coef;
    C_COEF_S_9_8_G  : sfix_coef;
    C_COEF_S_10_8_G : sfix_coef;
    C_COEF_S_11_8_G : sfix_coef;
    C_COEF_S_12_8_G : sfix_coef;
    C_COEF_S_13_8_G : sfix_coef;
    C_COEF_S_14_8_G : sfix_coef;
    C_COEF_S_15_8_G : sfix_coef;
    C_COEF_S_16_8_G : sfix_coef;
    C_COEF_S_17_8_G : sfix_coef
  );
  port (
    clk       : in std_logic;
    rst       : in std_logic;
    valid_in  : in std_logic;
    m_in      : in sfix32_vector(0 to 17);
    valid_out : out std_logic;
    v_out     : out sfix32_vector(0 to 17)
  );
end entity n8_prop_stageB;

architecture rtl of n8_prop_stageB is
  signal v_int : sfix32_vector(0 to 17);
begin

  v_int(0)  <= resize32(C_COEF_S_0_8_G  * m_in(0));
  v_int(1)  <= resize32(C_COEF_S_1_8_G  * m_in(1));
  v_int(2)  <= resize32(C_COEF_S_2_8_G  * m_in(2));
  v_int(3)  <= resize32(C_COEF_S_3_8_G  * m_in(3));
  v_int(4)  <= resize32(C_COEF_S_4_8_G  * m_in(4));
  v_int(5)  <= resize32(C_COEF_S_5_8_G  * m_in(5));
  v_int(6)  <= resize32(C_COEF_S_6_8_G  * m_in(6));
  v_int(7)  <= resize32(C_COEF_S_7_8_G  * m_in(7));
  v_int(8)  <= resize32(C_COEF_S_8_8_G  * m_in(8));
  v_int(9)  <= resize32(C_COEF_S_9_8_G  * m_in(9));
  v_int(10) <= resize32(C_COEF_S_10_8_G * m_in(10));
  v_int(11) <= resize32(C_COEF_S_11_8_G * m_in(11));
  v_int(12) <= resize32(C_COEF_S_12_8_G * m_in(12));
  v_int(13) <= resize32(C_COEF_S_13_8_G * m_in(13));
  v_int(14) <= resize32(C_COEF_S_14_8_G * m_in(14));
  v_int(15) <= resize32(C_COEF_S_15_8_G * m_in(15));
  v_int(16) <= resize32(C_COEF_S_16_8_G * m_in(16));
  v_int(17) <= resize32(C_COEF_S_17_8_G * m_in(17));

  process (clk)
  begin
    if rising_edge(clk) then
      v_out     <= v_int;
      if rst = '1' then
        valid_out <= '0';
      else
        valid_out <= valid_in;
      end if;
    end if;
  end process;
end architecture rtl;
