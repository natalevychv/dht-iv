-------------------------------------------------------------------------------
-- n8_prop_stageD.vhd
--
-- Stage D of the proposed 8-point DHT-IV architecture.
--
-- Sums the products from Stages B and C into the final transform
-- outputs. No multiplications.
--
-- Inputs:  v_in(0..17)  - products
-- Outputs: y(0..7)      - transform outputs
--
-- Latency: 1 clock cycle (output register).
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.fixed_types_pkg.all;

entity n8_prop_stageD is
  port (
    clk       : in std_logic;
    rst       : in std_logic;
    valid_in  : in std_logic;
    v_in      : in sfix32_vector(0 to 17);
    valid_out : out std_logic;
    y         : out sfix32_vector(0 to 7)
  );
end entity n8_prop_stageD;

architecture rtl of n8_prop_stageD is
  signal y_int : sfix32_vector(0 to 7);
  signal sum7_8   : sfix32;
  signal sum6_8   : sfix32;
  signal sum16_17   : sfix32;
  signal sum15_17   : sfix32;

begin
  sum7_8 <= resize32(v_in(7)+ v_in(8));
  sum6_8 <= resize32(v_in(6)+ v_in(8));
  sum16_17 <= resize32(v_in(16)+ v_in(17));
  sum15_17 <= resize32(v_in(15)+ v_in(17));


  y_int(0) <= resize32(v_in(0) + v_in(2) + sum6_8);
  y_int(1) <= resize32(v_in(10) + v_in(11) + sum16_17);
  y_int(2) <= resize32(v_in(1) + v_in(2) + sum7_8);
  y_int(3) <= resize32(v_in(9) + v_in(11) + sum15_17);
  y_int(4) <= resize32(v_in(3) + v_in(5) + sum6_8);
  y_int(5) <= resize32(v_in(13) + v_in(14) + sum16_17);
  y_int(6) <= resize32(v_in(4) + v_in(5) + sum7_8);
  y_int(7) <= resize32(v_in(12) + v_in(14) + sum15_17);

  process (clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        y         <= (others => (others => '0'));
        valid_out <= '0';
      else
        y         <= y_int;
        valid_out <= valid_in;
      end if;
    end if;
  end process;
end architecture rtl;
