-------------------------------------------------------------------------------
-- n5_prop_top.vhd
--
-- Top-level module for the proposed algorithm for 5-point DHT-IV
--
-- Pipeline:
--      Stage A: partial products
--      Stage B: intermediate sums
--      Stage C: final outputs
--
-- Total latency: 3 clocks
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.fixed_types_pkg.all;

entity n5_prop_top is
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        valid_in  : in  std_logic;
        x         : in  sfix32_vector(0 to 4);
        valid_out : out std_logic;
        y         : out sfix32_vector(0 to 4)
    );
end entity n5_prop_top;

architecture struct of n5_prop_top is

    signal valid_A, valid_B, valid_C : std_logic;

    signal dA_p_out : sfix32_vector(0 to 6);

    signal dB_p_out : sfix32_vector(0 to 5);

    constant C_COEF_S_0_5 : sfix32 := to_sfixed( 1.0000, 15, -16);
    constant C_COEF_S_1_5 : sfix32 := to_sfixed( 1.0000, 15, -16);
    constant C_COEF_S_2_5 : sfix32 := to_sfixed( 1.0000, 15, -16);
    constant C_COEF_S_3_5 : sfix32 := to_sfixed( 1.0000, 15, -16);
    constant C_COEF_S_4_5 : sfix32 := to_sfixed( 1.0000, 15, -16);
    constant C_COEF_S_5_5 : sfix32 := to_sfixed( 1.0000, 15, -16);
    constant C_COEF_S_6_5 : sfix32 := to_sfixed( 1.0000, 15, -16);

begin

    stageA : entity work.n5_prop_stageA
        generic map (
            C_COEF_S_0_5_G => C_COEF_S_0_5,
            C_COEF_S_1_5_G => C_COEF_S_1_5,
            C_COEF_S_2_5_G => C_COEF_S_2_5,
            C_COEF_S_3_5_G => C_COEF_S_3_5,
            C_COEF_S_4_5_G => C_COEF_S_4_5,
            C_COEF_S_5_5_G => C_COEF_S_5_5,
            C_COEF_S_6_5_G => C_COEF_S_6_5
        )
        port map (
            clk => clk,
            rst => rst,
            valid_in => valid_in,
            x => x,
            valid_out => valid_A,
            p => dA_p_out
        );

    stageB : entity work.n5_prop_stageB
        port map (
            clk => clk,
            rst => rst,
            valid_in => valid_A,
            p_in => dA_p_out,
            valid_out => valid_B,
            p_out => dB_p_out
        );

    stageC : entity work.n5_prop_stageC
        port map (
            clk => clk,
            rst => rst,
            valid_in => valid_B,
            p_in => dB_p_out,
            valid_out => valid_C,
            y => y
        );

    valid_out <= valid_C;

end architecture struct;
