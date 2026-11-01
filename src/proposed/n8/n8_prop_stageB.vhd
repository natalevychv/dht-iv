-------------------------------------------------------------------------------
-- n8_prop_stageB.vhd
--
-- Stage B of the proposed 8-point DHT-IV architecture.
--
-- Computes 9 coefficient multiplications (C_COEF_S_0_8 .. C_COEF_S_8_8,
-- passed as generics) on p(0..3) and their pre-addition sums.
-- p(4..7) are registered and passed on to Stage C.
--
-- Inputs:  p_in(0..7)   - butterfly outputs
-- Outputs: p_out(0..3)  - registered p(4..7)
--          v_out(0..8)  - products of the first half
--
-- Latency: 1 clock cycle (output register).
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.fixed_types_pkg.all;

entity n8_prop_stageB is
  generic (
    C_COEF_S_0_8_G : sfix32;
    C_COEF_S_1_8_G : sfix32;
    C_COEF_S_2_8_G : sfix32;
    C_COEF_S_3_8_G : sfix32;
    C_COEF_S_4_8_G : sfix32;
    C_COEF_S_5_8_G : sfix32;
    C_COEF_S_6_8_G : sfix32;
    C_COEF_S_7_8_G : sfix32;
    C_COEF_S_8_8_G : sfix32
  );
  port (
    clk       : in std_logic;
    rst       : in std_logic;
    valid_in  : in std_logic;
    p_in      : in sfix32_vector(0 to 7);
    valid_out : out std_logic;
    p_out     : out sfix32_vector(0 to 3);
    v_out     : out sfix32_vector(0 to 8)
  );
end entity n8_prop_stageB;

architecture rtl of n8_prop_stageB is
  signal p_int  : sfix32_vector(0 to 3);
  signal v_int  : sfix32_vector(0 to 8);
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

  
  p_int(0) <= p_in(4);
  p_int(1) <= p_in(5);
  p_int(2) <= p_in(6);
  p_int(3) <= p_in(7);
  

  v_int(0) <= resize32(C_COEF_S_0_8_G * p_in(0));
  v_int(1) <= resize32(C_COEF_S_1_8_G * p_in(1));
  v_int(2) <= resize32(C_COEF_S_2_8_G * sum0_1);
  v_int(3) <= resize32(C_COEF_S_3_8_G * p_in(2));
  v_int(4) <= resize32(C_COEF_S_4_8_G * p_in(3));
  v_int(5) <= resize32(C_COEF_S_5_8_G * sum2_3);
  v_int(6) <= resize32(C_COEF_S_6_8_G * sum0_2);
  v_int(7) <= resize32(C_COEF_S_7_8_G * sum1_3);
  v_int(8) <= resize32(C_COEF_S_8_8_G * sum_0_1_2_3);
  process (clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        p_out     <= (others => (others => '0'));
        v_out     <= (others => (others => '0'));
        valid_out <= '0';
      else
        p_out     <= p_int;
        v_out     <= v_int;
        valid_out <= valid_in;
      end if;
    end if;
  end process;
end architecture rtl;
