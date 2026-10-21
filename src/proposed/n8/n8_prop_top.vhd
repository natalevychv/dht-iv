-------------------------------------------------------------------------------
-- n8_prop_top.vhd
--
-- Top-level module for the proposed algorithm for 8-point DHT-IV
--
-- Pipeline:
--      Stage A: input butterflies
--      Stage B: coefficient multiplications (first half)
--      Stage C: coefficient multiplications (second half)
--      Stage D: final outputs
--
-- Total latency: 4 clocks
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.fixed_types_pkg.all;

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

    signal valid_A, valid_B, valid_C, valid_D : std_logic;

    signal dA_p_out : sfix32_vector(0 to 7);

    signal dB_p_out : sfix32_vector(0 to 3);
    signal dB_v_out : sfix32_vector(0 to 8);

    signal dC_v_out : sfix32_vector(0 to 17);

    constant C_COEF_S_0_8 : sfix32 := to_sfixed( 1.0000, 15, -16);
    constant C_COEF_S_1_8 : sfix32 := to_sfixed( 1.0000, 15, -16);
    constant C_COEF_S_2_8 : sfix32 := to_sfixed( 1.0000, 15, -16);
    constant C_COEF_S_3_8 : sfix32 := to_sfixed( 1.0000, 15, -16);
    constant C_COEF_S_4_8 : sfix32 := to_sfixed( 1.0000, 15, -16);
    constant C_COEF_S_5_8 : sfix32 := to_sfixed( 1.0000, 15, -16);
    constant C_COEF_S_6_8 : sfix32 := to_sfixed( 1.0000, 15, -16);
    constant C_COEF_S_7_8 : sfix32 := to_sfixed( 1.0000, 15, -16);
    constant C_COEF_S_8_8 : sfix32 := to_sfixed( 1.0000, 15, -16);
    constant C_COEF_S_9_8 : sfix32 := to_sfixed( 1.0000, 15, -16);
    constant C_COEF_S_10_8 : sfix32 := to_sfixed( 1.0000, 15, -16);
    constant C_COEF_S_11_8 : sfix32 := to_sfixed( 1.0000, 15, -16);
    constant C_COEF_S_12_8 : sfix32 := to_sfixed( 1.0000, 15, -16);
    constant C_COEF_S_13_8 : sfix32 := to_sfixed( 1.0000, 15, -16);
    constant C_COEF_S_14_8 : sfix32 := to_sfixed( 1.0000, 15, -16);
    constant C_COEF_S_15_8 : sfix32 := to_sfixed( 1.0000, 15, -16);
    constant C_COEF_S_16_8 : sfix32 := to_sfixed( 1.0000, 15, -16);
    constant C_COEF_S_17_8 : sfix32 := to_sfixed( 1.0000, 15, -16);

begin

    stageA : entity work.n8_prop_stageA
        port map (
            clk => clk,
            rst => rst,
            valid_in => valid_in,
            x => x,
            valid_out => valid_A,
            p => dA_p_out
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
            C_COEF_S_8_8_G => C_COEF_S_8_8
        )
        port map (
            clk => clk,
            rst => rst,
            valid_in => valid_A,
            p_in => dA_p_out,
            valid_out => valid_B,
            p_out => dB_p_out,
            v_out => dB_v_out
        );

    stageC : entity work.n8_prop_stageC
        generic map (
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
            valid_in => valid_B,
            p_in => dB_p_out,
            v_in => dB_v_out,
            valid_out => valid_C,
            v_out => dC_v_out
        );

    stageD : entity work.n8_prop_stageD
        port map (
            clk => clk,
            rst => rst,
            valid_in => valid_C,
            v_in => dC_v_out,
            valid_out => valid_D,
            y => y
        );

    valid_out <= valid_D;

end architecture struct;
