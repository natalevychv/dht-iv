-------------------------------------------------------------------------------
-- n3_prop_top.vhd
--
-- Top-level module for the proposed algorithm for 3-point DHT-IV
--
-- Pipeline:
--      Stage A: input sums (multiplier operands)
--      Stage B: coefficient multiplications (2, multiplications only)
--      Stage C: final outputs
--
-- Total latency: 3 clocks
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.fixed_types_pkg.all;
use work.n3_coef_pkg.all;

entity n3_prop_top is
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        valid_in  : in  std_logic;
        x         : in  sfix32_vector(0 to 2);
        valid_out : out std_logic;
        y         : out sfix32_vector(0 to 2)
    );
end entity n3_prop_top;

architecture struct of n3_prop_top is

    signal vA, vB, vC : std_logic;

    signal dA_x_out : sfix32_vector(0 to 2);
    signal dA_m     : sfix32_vector(0 to 1);

    signal dB_x_out : sfix32_vector(0 to 2);
    signal dB_p_0   : sfix32;
    signal dB_y_1   : sfix32;

begin

    stageA : entity work.n3_prop_stageA
        port map (clk => clk, rst => rst, valid_in => valid_in,
                   x => x, valid_out => vA, x_out => dA_x_out,
                   m => dA_m);

    stageB : entity work.n3_prop_stageB
        generic map (C_COEF_S_0_3_G => C_COEF_S_0_3,
                     C_COEF_S_1_3_G => C_COEF_S_1_3)
        port map (clk => clk, rst => rst, valid_in => vA,
                   x_in => dA_x_out, m_in => dA_m, valid_out => vB,
                   x_out => dB_x_out, p_0 => dB_p_0, y_1 => dB_y_1);

    stageC : entity work.n3_prop_stageC
        port map (clk => clk, rst => rst, valid_in => vB,
                   x => dB_x_out, p_0 => dB_p_0, y_1 => dB_y_1,
                   valid_out => vC, y => y);

    valid_out <= vC;

end architecture struct;
