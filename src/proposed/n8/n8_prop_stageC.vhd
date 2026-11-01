-------------------------------------------------------------------------------
-- n8_prop_stageC.vhd
--
-- Stage C of the proposed 8-point DHT-IV architecture.
--
-- Computes 9 coefficient multiplications (C_COEF_S_9_8 .. C_COEF_S_17_8,
-- passed as generics) on p(4..7) and their pre-addition sums.
-- Products from Stage B are passed through as v(0..8).
--
-- Inputs:  p_in(0..3)    - registered p(4..7)
--          v_in(0..8)    - products of the first half
-- Outputs: v_out(0..17)  - all products
--
-- Latency: 1 clock cycle (output register).
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.fixed_types_pkg.all;

entity n8_prop_stageC is
  generic (
    C_COEF_S_9_8_G : sfix_coef;
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
    p_in      : in sfix32_vector(0 to 3);
    v_in      : in sfix32_vector(0 to 8);
    valid_out : out std_logic;
    v_out     : out sfix32_vector(0 to 17)
  );
end entity n8_prop_stageC;

architecture rtl of n8_prop_stageC is
  signal v_int  : sfix32_vector(0 to 17);
  signal sum0_1   : sfix32;
  signal sum2_3   : sfix32;
  signal sum0_2   : sfix32;
  signal sum1_3 : sfix32;
  signal sum_0_1_2_3   : sfix32;

begin
  sum0_1   <= resize32(p_in(1) + p_in(0));
  sum2_3   <= resize32(p_in(3) + p_in(2));
  sum0_2   <= resize32(p_in(0) + p_in(2));
  sum1_3   <= resize32(p_in(1) + p_in(3));
  sum_0_1_2_3 <= resize32(sum1_3 + sum0_2);

  
  v_int(0) <= v_in(0);
  v_int(1) <= v_in(1);
  v_int(2) <= v_in(2);
  v_int(3) <= v_in(3);
  v_int(4) <= v_in(4);
  v_int(5) <= v_in(5);
  v_int(6) <= v_in(6);
  v_int(7) <= v_in(7);
  v_int(8) <= v_in(8);

  v_int(9) <= resize32(C_COEF_S_9_8_G * p_in(0));
  v_int(10) <= resize32(C_COEF_S_10_8_G * p_in(1));
  v_int(11) <= resize32(C_COEF_S_11_8_G * sum0_1);
  v_int(12) <= resize32(C_COEF_S_12_8_G * p_in(2));
  v_int(13) <= resize32(C_COEF_S_13_8_G * p_in(3));
  v_int(14) <= resize32(C_COEF_S_14_8_G * sum2_3);
  v_int(15) <= resize32(C_COEF_S_15_8_G * sum0_2);
  v_int(16) <= resize32(C_COEF_S_16_8_G * sum1_3);
  v_int(17) <= resize32(C_COEF_S_17_8_G * sum_0_1_2_3);
  process (clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        v_out     <= (others => (others => '0'));
        valid_out <= '0';
      else
        v_out     <= v_int;
        valid_out <= valid_in;
      end if;
    end if;
  end process;
end architecture rtl;
