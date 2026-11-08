-------------------------------------------------------------------------------
-- fixed_types_pkg.vhd
--
-- Common package shared by all algorithms (naive and proposed).
-- Defines the Q15.16 fixed-point format:
-- 32 bits total: 1 sign bit, 15 integer bits, 16 fractional bits.
--
-- Resolution: 2^-16 ~= 0.0000153
-- Range:     -32768 .. +32767.99998
--
-- Constant coefficients use a separate Q1.30 format (sfix_coef):
-- 32 bits total: 1 sign bit, 1 integer bit, 30 fractional bits.
--
-- Resolution: 2^-30 ~= 0.00000000093
-- Range:     -2 .. +1.999999999
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use ieee.fixed_float_types.all;

package fixed_types_pkg is

    -- Q15.16 format: sfixed(15 downto -16), 32 bits total
    subtype sfix32 is sfixed(15 downto -16);

    type sfix32_vector is array (natural range <>) of sfix32;

    constant SFIX32_ZERO : sfix32 := to_sfixed(0.0, 15, -16);

    -- Q1.30 format for constant coefficients: sfixed(1 downto -30), 32 bits.
    -- All DHT-IV coefficients satisfy |c| < 2. A product sfix_coef * sfix32
    -- is resized back to Q15.16 with resize32().
    subtype sfix_coef is sfixed(1 downto -30);

    -- Resize a product to Q15.16: round half up (add 2^-17, then drop the
    -- extra fractional bits), error <= 1/2 LSB. No saturation: products
    -- of the transforms are a few units for inputs with |x| <= 1.
    -- Used for products, which have more fractional bits than Q15.16.
    -- Conversion between sfix32 and std_logic_vector(31 downto 0)
    -- is provided by ieee.fixed_pkg: to_slv() and to_sfixed().
    function resize32(x : sfixed) return sfix32;

    -- Resize a sum of sfix32 values to Q15.16 by dropping the extra integer
    -- bits (two's complement wrap, no rounding or saturation logic). Exact
    -- as long as the result fits in Q15.16, which holds for inputs with
    -- |x| <= 1: all intermediate values of the transforms are a few units.
    -- In a chain of additions intermediate overflows cancel out, only the
    -- final sum has to fit.
    function wrap32(x : sfixed) return sfix32;

    -- Addition / subtraction with the result wrapped to Q15.16.
    function add32(a, b : sfix32) return sfix32;
    function sub32(a, b : sfix32) return sfix32;

end package fixed_types_pkg;

package body fixed_types_pkg is

    -- Half of the Q15.16 LSB (2^-17). The range starts at bit 0 so that
    -- the constant is positive (a 1-bit sfixed would be its sign bit).
    constant HALF_LSB : sfixed(0 downto -17) := to_sfixed(2.0 ** (-17), 0, -17);

    function resize32(x : sfixed) return sfix32 is
    begin
        return resize(x + HALF_LSB, 15, -16, fixed_wrap, fixed_truncate);
    end function;

    function wrap32(x : sfixed) return sfix32 is
    begin
        return resize(x, 15, -16, fixed_wrap, fixed_truncate);
    end function;

    function add32(a, b : sfix32) return sfix32 is
    begin
        return wrap32(a + b);
    end function;

    function sub32(a, b : sfix32) return sfix32 is
    begin
        return wrap32(a - b);
    end function;

end package body fixed_types_pkg;
