-------------------------------------------------------------------------------
-- n7_prop_top.vhd
--
-- Top-level module for the proposed algorithm for 7-point DHT-IV
--
-- Pipeline:
--      Stage A: input butterflies
--      Stage B: coefficient multiplications
--      Stage C: intermediate sums
--      Stage D: final outputs
--
-- Total latency: 4 clocks
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.fixed_types_pkg.all;

entity n7_prop_top is
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        valid_in  : in  std_logic;
        x         : in  sfix32_vector(0 to 6);
        valid_out : out std_logic;
        y         : out sfix32_vector(0 to 6)
    );
end entity n7_prop_top;

architecture struct of n7_prop_top is

    signal valid_A, valid_B, valid_C, valid_D : std_logic;

    signal dA_p_out : sfix32_vector(0 to 7);

    signal dB_p_out : sfix32_vector(0 to 9);

    signal dC_p_out : sfix32_vector(0 to 7);

    constant C_COEF_S_0_7 : sfix32 := to_sfixed( 1.0000, 15, -16);
    constant C_COEF_S_1_7 : sfix32 := to_sfixed( 1.0000, 15, -16);
    constant C_COEF_S_3_7 : sfix32 := to_sfixed( 1.0000, 15, -16);
    constant C_COEF_S_4_7 : sfix32 := to_sfixed( 1.0000, 15, -16);
    constant C_COEF_S_5_7 : sfix32 := to_sfixed( 1.0000, 15, -16);
    constant C_COEF_S_6_7 : sfix32 := to_sfixed( 1.0000, 15, -16);
    constant C_COEF_S_7_7 : sfix32 := to_sfixed( 1.0000, 15, -16);
    constant C_COEF_S_8_7 : sfix32 := to_sfixed( 1.0000, 15, -16);
    constant C_COEF_S_9_7 : sfix32 := to_sfixed( 1.0000, 15, -16);

begin

    stageA : entity work.n7_prop_stageA
        port map (
            clk => clk,
            rst => rst,
            valid_in => valid_in,
            x => x,
            valid_out => valid_A,
            p => dA_p_out
        );

    stageB : entity work.n7_prop_stageB
        generic map (
            C_COEF_S_0_7_G => C_COEF_S_0_7,
            C_COEF_S_1_7_G => C_COEF_S_1_7,
            C_COEF_S_2_7_G => C_COEF_S_2_7,
            C_COEF_S_3_7_G => C_COEF_S_3_7,
            C_COEF_S_4_7_G => C_COEF_S_4_7,
            C_COEF_S_5_7_G => C_COEF_S_5_7,
            C_COEF_S_6_7_G => C_COEF_S_6_7,
            C_COEF_S_7_7_G => C_COEF_S_7_7,
            C_COEF_S_8_7_G => C_COEF_S_8_7,
            C_COEF_S_9_7_G => C_COEF_S_9_7
        )
        port map (
            clk => clk,
            rst => rst,
            valid_in => valid_A,
            p_in => dA_p_out,
            valid_out => valid_B,
            p_out => dB_p_out
        );

    stageC : entity work.n7_prop_stageC
        port map (
            clk => clk,
            rst => rst,
            valid_in => valid_B,
            p_in => dB_p_out,
            valid_out => valid_C,
            p_out => dC_p_out
        );

    stageD : entity work.n7_prop_stageD
        port map (
            clk => clk,
            rst => rst,
            valid_in => valid_C,
            p_in => dC_p_out,
            valid_out => valid_D,
            y => y
        );

    valid_out <= valid_D;

end architecture struct;
