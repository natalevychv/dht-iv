-------------------------------------------------------------------------------
-- n5_prop_stageB.vhd
--
-- Stage B of the proposed 5-point DHT-IV architecture.
--
-- Combines partial products from Stage A into intermediate sums;
-- p(2) and p(3) are passed through. No multiplications.
--
-- Inputs:  p_in(0..6)   - partial products
-- Outputs: p_out(0..5)  - intermediate sums
--
-- Latency: 1 clock cycle (output register).
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.fixed_types_pkg.all;

entity n5_prop_stageB is
  port (
    clk       : in std_logic;
    rst       : in std_logic;
    valid_in  : in std_logic;
    p_in      : in sfix32_vector(0 to 6);
    valid_out : out std_logic;
    p_out     : out sfix32_vector(0 to 5)
  );
end entity n5_prop_stageB;

architecture rtl of n5_prop_stageB is
  signal p_int : sfix32_vector(0 to 5);
  signal sum2_3    : sfix32;
  signal sum2_n3   : sfix32;
  signal sum4_6    : sfix32;
  signal sum5_6    : sfix32;
begin

  sum2_3  <= resize32(p_in(2) + p_in(3));
  sum2_n3 <= resize32(p_in(2) - p_in(3));
  sum4_6  <= resize32(p_in(4) + p_in(6));
  sum5_6  <= resize32(p_in(5) + p_in(6));

  p_int(0) <= p_in(0);
  p_int(1) <= p_in(1);
  p_int(2) <= resize32(sum2_3 + sum4_6);
  p_int(3) <= resize32(sum2_n3 + sum5_6);
  p_int(4) <= resize32(sum2_3 - sum4_6);
  p_int(5) <= resize32(sum2_n3 - sum5_6);


  process (clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        p_out     <= (others => (others => '0'));
        valid_out <= '0';
      else
        p_out     <= p_int;
        valid_out <= valid_in;
      end if;
    end if;
  end process;
end architecture rtl;
