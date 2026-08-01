-------------------------------------------------------------------------------
-- n4_prop_top.vhd
--
-- Top-level module for the proposed algorithm for 4-point DHT-IV
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

entity n4_prop_top is
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        valid_in  : in  std_logic;
        x         : in  sfix32_vector(0 to 3);
        valid_out : out std_logic;
        y         : out sfix32_vector(0 to 3)
    );
end entity n4_prop_top;

architecture struct of n4_prop_top is

    signal valid_A, valid_B, valid_C : std_logic;

    signal dA_p_out : sfix32_vector(0 to 5);

    signal dB_p_out : sfix32_vector(0 to 3);

    constant C_COEF_S_0_4 : sfix32 := to_sfixed( 1.0000, 15, -16);
    constant C_COEF_S_1_4 : sfix32 := to_sfixed( 1.0000, 15, -16);
    constant C_COEF_S_2_4 : sfix32 := to_sfixed( 1.0000, 15, -16);
    constant C_COEF_S_3_4 : sfix32 := to_sfixed( 1.0000, 15, -16);
    constant C_COEF_S_4_4 : sfix32 := to_sfixed( 1.0000, 15, -16);
    constant C_COEF_S_5_4 : sfix32 := to_sfixed( 1.0000, 15, -16);

begin

    stageA : entity work.n4_prop_stageA
        generic map (
            C_COEF_S_0_4_G => C_COEF_S_0_4,
            C_COEF_S_1_4_G => C_COEF_S_1_4,
            C_COEF_S_2_4_G => C_COEF_S_2_4,
            C_COEF_S_3_4_G => C_COEF_S_3_4,
            C_COEF_S_4_4_G => C_COEF_S_4_4,
            C_COEF_S_5_4_G => C_COEF_S_5_4
        )
        port map (
            clk => clk,
            rst => rst,
            valid_in => valid_in,
            x => x,
            valid_out => valid_A,
            p => dA_p_out
        );

    stageB : entity work.n4_prop_stageB
        port map (
            clk => clk,
            rst => rst,
            valid_in => valid_A,
            p_in => dA_p_out,
            valid_out => valid_B,
            p_out => dB_p_out
        );

    stageC : entity work.n4_prop_stageC
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
