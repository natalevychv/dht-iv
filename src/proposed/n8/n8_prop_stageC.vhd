-------------------------------------------------------------------------------
-- n8_prop_stageC.vhd
--
-- Stage C of the proposed 8-point DHT-IV architecture.
--
-- Sums the products from Stage B into the final transform
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

entity n8_prop_stageC is
  port (
    clk       : in std_logic;
    rst       : in std_logic;
    valid_in  : in std_logic;
    v_in      : in sfix32_vector(0 to 17);
    valid_out : out std_logic;
    y         : out sfix32_vector(0 to 7)
  );
end entity n8_prop_stageC;

architecture rtl of n8_prop_stageC is
  signal y_int : sfix32_vector(0 to 7);
  signal sum7_8   : sfix32;
  signal sum6_8   : sfix32;
  signal sum16_17   : sfix32;
  signal sum15_17   : sfix32;

begin
  sum7_8 <= wrap32(v_in(7)+ v_in(8));
  sum6_8 <= wrap32(v_in(6)+ v_in(8));
  sum16_17 <= wrap32(v_in(16)+ v_in(17));
  sum15_17 <= wrap32(v_in(15)+ v_in(17));


  y_int(0) <= wrap32(v_in(0) + v_in(2) + sum6_8);
  y_int(1) <= wrap32(v_in(10) + v_in(11) + sum16_17);
  y_int(2) <= wrap32(v_in(1) + v_in(2) + sum7_8);
  y_int(3) <= wrap32(v_in(9) + v_in(11) + sum15_17);
  y_int(4) <= wrap32(v_in(3) + v_in(5) + sum6_8);
  y_int(5) <= wrap32(v_in(13) + v_in(14) + sum16_17);
  y_int(6) <= wrap32(v_in(4) + v_in(5) + sum7_8);
  y_int(7) <= wrap32(v_in(12) + v_in(14) + sum15_17);

  process (clk)
  begin
    if rising_edge(clk) then
      y         <= y_int;
      if rst = '1' then
        valid_out <= '0';
      else
        valid_out <= valid_in;
      end if;
    end if;
  end process;
end architecture rtl;
