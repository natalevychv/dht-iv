-------------------------------------------------------------------------------
-- n6_prop_top.vhd
--
-- Top-level module for the proposed algorithm for 6-point DHT-IV
--
-- Pipeline:
--      Stage A: input butterflies and pre-addition sums (multiplier operands)
--      Stage B: coefficient multiplications (4, multiplications only)
--               and scaling by 1/4
--      Stage C: intermediate sums
--      Stage D: final outputs
--
-- Total latency: 4 clocks
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.fixed_types_pkg.all;
use work.n6_coef_pkg.all;

entity n6_prop_top is
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        valid_in  : in  std_logic;
        x         : in  sfix32_vector(0 to 5);
        valid_out : out std_logic;
        y         : out sfix32_vector(0 to 5)
    );
end entity n6_prop_top;

architecture struct of n6_prop_top is

    signal valid_A, valid_B, valid_C, valid_D : std_logic;

    signal dA_m_out : sfix32_vector(0 to 5);

    signal dB_p_out : sfix32_vector(0 to 5);

    signal dC_p_out : sfix32_vector(0 to 5);

begin

    stageA : entity work.n6_prop_stageA
        port map (
            clk => clk,
            rst => rst,
            valid_in => valid_in,
            x => x,
            valid_out => valid_A,
            m => dA_m_out
        );

    stageB : entity work.n6_prop_stageB
        generic map (
            C_COEF_S_1_6_G => C_COEF_S_1_6,
            C_COEF_S_2_6_G => C_COEF_S_2_6,
            C_COEF_S_3_6_G => C_COEF_S_3_6,
            C_COEF_S_4_6_G => C_COEF_S_4_6
        )
        port map (
            clk => clk,
            rst => rst,
            valid_in => valid_A,
            m_in => dA_m_out,
            valid_out => valid_B,
            p_out => dB_p_out
        );

    stageC : entity work.n6_prop_stageC
        port map (
            clk => clk,
            rst => rst,
            valid_in => valid_B,
            p_in => dB_p_out,
            valid_out => valid_C,
            p_out => dC_p_out
        );

    stageD : entity work.n6_prop_stageD
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
