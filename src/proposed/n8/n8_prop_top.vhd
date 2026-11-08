-------------------------------------------------------------------------------
-- n8_prop_top.vhd
--
-- Top-level module for the proposed algorithm for 8-point DHT-IV
--
-- Pipeline:
--      Stage A: input butterflies and pre-addition sums (multiplier operands)
--      Stage B: coefficient multiplications (18, multiplications only)
--      Stage C: final outputs
--
-- Total latency: 3 clocks
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.fixed_types_pkg.all;
use work.n8_coef_pkg.all;

entity n8_prop_top is
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        valid_in  : in  std_logic;
        x         : in  sfix32_vector(0 to 7);
        valid_out : out std_logic;
        y         : out sfix32_vector(0 to 7)
    );
end entity n8_prop_top;

architecture struct of n8_prop_top is

    signal valid_A, valid_B, valid_C : std_logic;

    signal dA_m_out : sfix32_vector(0 to 17);

    signal dB_v_out : sfix32_vector(0 to 17);

begin

    stageA : entity work.n8_prop_stageA
        port map (
            clk => clk,
            rst => rst,
            valid_in => valid_in,
            x => x,
            valid_out => valid_A,
            m => dA_m_out
        );

    stageB : entity work.n8_prop_stageB
        generic map (
            C_COEF_S_0_8_G => C_COEF_S_0_8,
            C_COEF_S_1_8_G => C_COEF_S_1_8,
            C_COEF_S_2_8_G => C_COEF_S_2_8,
            C_COEF_S_3_8_G => C_COEF_S_3_8,
            C_COEF_S_4_8_G => C_COEF_S_4_8,
            C_COEF_S_5_8_G => C_COEF_S_5_8,
            C_COEF_S_6_8_G => C_COEF_S_6_8,
            C_COEF_S_7_8_G => C_COEF_S_7_8,
            C_COEF_S_8_8_G => C_COEF_S_8_8,
            C_COEF_S_9_8_G => C_COEF_S_9_8,
            C_COEF_S_10_8_G => C_COEF_S_10_8,
            C_COEF_S_11_8_G => C_COEF_S_11_8,
            C_COEF_S_12_8_G => C_COEF_S_12_8,
            C_COEF_S_13_8_G => C_COEF_S_13_8,
            C_COEF_S_14_8_G => C_COEF_S_14_8,
            C_COEF_S_15_8_G => C_COEF_S_15_8,
            C_COEF_S_16_8_G => C_COEF_S_16_8,
            C_COEF_S_17_8_G => C_COEF_S_17_8
        )
        port map (
            clk => clk,
            rst => rst,
            valid_in => valid_A,
            m_in => dA_m_out,
            valid_out => valid_B,
            v_out => dB_v_out
        );

    stageC : entity work.n8_prop_stageC
        port map (
            clk => clk,
            rst => rst,
            valid_in => valid_B,
            v_in => dB_v_out,
            valid_out => valid_C,
            y => y
        );

    valid_out <= valid_C;

end architecture struct;
