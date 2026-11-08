-------------------------------------------------------------------------------
-- n6_prop_stageC.vhd
--
-- Stage C of the proposed 6-point DHT-IV architecture.
--
-- Forms intermediate sums; scaling by 1/2 is implemented as
-- arithmetic right shifts (the shifted-out bit is truncated).
-- No multiplications.
--
-- Inputs:  p_in(0..5)   - products and scaled sums
-- Outputs: p_out(0..5)  - intermediate sums
--
-- Latency: 1 clock cycle (output register).
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.fixed_types_pkg.all;

entity n6_prop_stageC is
  port (
    clk       : in std_logic;
    rst       : in std_logic;
    valid_in  : in std_logic;
    p_in      : in sfix32_vector(0 to 5);
    valid_out : out std_logic;
    p_out     : out sfix32_vector(0 to 5)
  );
end entity n6_prop_stageC;

architecture rtl of n6_prop_stageC is
  signal p_int : sfix32_vector(0 to 5);
  signal shift2  : sfix32;
  signal shift3  : sfix32;
begin
  shift2 <= wrap32(shift_right(p_in(2), 1));
  shift3 <= wrap32(shift_right(p_in(3), 1));
  p_int(0) <= wrap32(shift2 + p_in(0) + p_in(1));
  p_int(1) <= wrap32(p_in(2) - p_in(1));
  p_int(2) <= wrap32(-shift2 - p_in(1) + p_in(0));
  p_int(3) <= wrap32(p_in(5) + p_in(4) - shift3);
  p_int(4) <= wrap32(p_in(4) + p_in(3));
  p_int(5) <= wrap32(p_in(5) - p_in(4) + shift3);

  process (clk)
  begin
    if rising_edge(clk) then
      p_out     <= p_int;
      if rst = '1' then
        valid_out <= '0';
      else
        valid_out <= valid_in;
      end if;
    end if;
  end process;
end architecture rtl;
