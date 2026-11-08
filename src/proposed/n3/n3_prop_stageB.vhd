-------------------------------------------------------------------------------
-- n3_prop_stageB.vhd
--
-- Stage B of the proposed 3-point DHT-IV architecture.
--
-- Computes the 2 coefficient multiplications
-- p_0 = m(0) * C_COEF_S_0_3 and y_1 = m(1) * C_COEF_S_1_3 (coefficients
-- passed as generics). Output y(1) is final after this stage.
-- Multiplications only: the operands are formed in Stage A. The input
-- vector is registered and passed on to Stage C.
--
-- Inputs:  x_in(0..2)   - registered input samples
--          m_in(0..1)   - multiplier operands
-- Outputs: x_out(0..2)  - registered input samples
--          p_0          - partial product
--          y_1          - final output y(1)
--
-- Latency: 1 clock cycle (output register).
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.fixed_types_pkg.all;

entity n3_prop_stageB is
  generic (
    C_COEF_S_0_3_G : sfix_coef;
    C_COEF_S_1_3_G : sfix_coef
  );
  port (
    clk       : in std_logic;
    rst       : in std_logic;
    valid_in  : in std_logic;
    x_in      : in sfix32_vector(0 to 2);
    m_in      : in sfix32_vector(0 to 1);
    valid_out : out std_logic;
    x_out     : out sfix32_vector(0 to 2);
    p_0       : out sfix32;
    y_1       : out sfix32
  );
end entity n3_prop_stageB;

architecture rtl of n3_prop_stageB is
  signal p_0_int : sfix32;
  signal y_1_int : sfix32;
begin

  p_0_int <= resize32(m_in(0) * C_COEF_S_0_3_G);
  y_1_int <= resize32(m_in(1) * C_COEF_S_1_3_G);

  process (clk)
  begin
    if rising_edge(clk) then
      x_out     <= x_in;
      p_0       <= p_0_int;
      y_1       <= y_1_int;
      if rst = '1' then
        valid_out <= '0';
      else
        valid_out <= valid_in;
      end if;
    end if;
  end process;
end architecture rtl;
