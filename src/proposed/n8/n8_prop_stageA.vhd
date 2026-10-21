-------------------------------------------------------------------------------
-- n8_prop_stageA.vhd
--
-- Stage A of the proposed 8-point DHT-IV architecture.
--
-- Input butterflies on the pairs (x0,x3), (x1,x2), (x4,x7), (x5,x6).
-- No multiplications.
--
-- Inputs:  x(0..7)  - input samples
-- Outputs: p(0..7)  - butterfly outputs
--
-- Latency: 1 clock cycle (output register).
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.fixed_types_pkg.all;

entity n8_prop_stageA is
  port (
    clk       : in std_logic;
    rst       : in std_logic;
    valid_in  : in std_logic;
    x         : in sfix32_vector(0 to 7);
    valid_out : out std_logic;
    p         : out sfix32_vector(0 to 7)
  );
end entity n8_prop_stageA;

architecture rtl of n8_prop_stageA is
  signal p_int : sfix32_vector(0 to 7);
begin

  p_int(0) <= resize32(x(7) - x(4));
  p_int(1) <= resize32(x(6) - x(5));
  p_int(2) <= resize32(x(0) + x(3));
  p_int(3) <= resize32(-x(1) - x(2));
  p_int(4) <= resize32(x(7) + x(4));
  p_int(5) <= resize32(x(6) + x(5));
  p_int(6) <= resize32(x(0) - x(3));
  p_int(7) <= resize32(-x(1) + x(2));

  process (clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        p         <= (others => (others => '0'));
        valid_out <= '0';
      else
        p         <= p_int;
        valid_out <= valid_in;
      end if;
    end if;
  end process;
end architecture rtl;
