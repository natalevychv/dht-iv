-------------------------------------------------------------------------------
-- n3_prop_top.vhd
--
-- Top-level implementation of the proposed N3 architecture.
-- Five-stage pipelined design implementing six transformation matrices.
-- Stage 1 combines Matrix5 (5x3) and Matrix4 (5x5), producing a
-- 5-element intermediate vector from the 3-element input vector.
--
-- Total latency: 5 clock cycles.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.fixed_types_pkg.all;

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

    signal vM_5_M_4, vM_3, vM_2, vM_1, vM_0 : std_logic;

    signal dM_5_M_4 : sfix32_vector(0 to 4);
    signal dM_3 : sfix32_vector(0 to 4);
    signal dM_2 : sfix32_vector(0 to 4);
    signal dM_1 : sfix32_vector(0 to 3);

    constant COEF_A : sfix32 := to_sfixed(-0.2113, 15, -16);
    constant COEF_B : sfix32 := to_sfixed( 0.5774, 15, -16);

begin

    stage_M_5_M_4 : entity work.n3_prop_stage_M_5_M_4
        port map (clk => clk, rst => rst, valid_in => valid_in,
                   x => x, valid_out => vM_5_M_4, y => dM_5_M_4);

    stage_M_3 : entity work.n3_prop_stage_M_3
        port map (clk => clk, rst => rst, valid_in => vM_5_M_4,
                   x => dM_5_M_4, valid_out => vM_3, y => dM_3);

    stage_M_2 : entity work.n3_prop_stage_M_2
        generic map (COEF_A_G => COEF_A,
                     COEF_B_G => COEF_B)
        port map (clk => clk, rst => rst, valid_in => vM_3,
                   x => dM_3, valid_out => vM_2, y => dM_2);

    stage_M_1 : entity work.n3_prop_stage_M_1
        port map (clk => clk, rst => rst, valid_in => vM_2,
                   x => dM_2, valid_out => vM_1, y => dM_1);

    stage_M_0 : entity work.n3_prop_stage_M_0
        port map (clk => clk, rst => rst, valid_in => vM_1,
                   x => dM_1, valid_out => vM_0, y => y);

    valid_out <= vM_0;

end architecture struct;
