-------------------------------------------------------------------------------
-- n3_prop_top.vhd
--
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

    signal vA, vB : std_logic;

    signal dA_x_out : sfix32_vector(0 to 2);
    signal dA_p_0   : sfix32;
    signal dA_y_1   : sfix32;

    constant C_COEF_S_0_3 : sfix32 := to_sfixed(-0.2113, 15, -16);
    constant C_COEF_S_1_3 : sfix32 := to_sfixed( 0.5774, 15, -16);

begin

    stageA : entity work.n3_prop_stageA
        generic map (C_COEF_S_0_3_G => C_COEF_S_0_3,
                     C_COEF_S_1_3_G => C_COEF_S_1_3)
        port map (clk => clk, rst => rst, valid_in => valid_in,
                   x => x, valid_out => vA, x_out => dA_x_out,
                   p_0 => dA_p_0, y_1 => dA_y_1);

    stageB : entity work.n3_prop_stageB
        port map (clk => clk, rst => rst, valid_in => vA,
                   x => dA_x_out, p_0 => dA_p_0, y_1 => dA_y_1,
                   valid_out => vB, y => y);

    valid_out <= vB;

end architecture struct;
