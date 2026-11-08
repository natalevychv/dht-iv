#!/usr/bin/env python3
"""
gen_naive.py

Generates the naive (direct matrix-vector) DHT-IV modules
src/naive/n<N>/n<N>_naive.vhd for N = 3..8.

    c[k][n] = (1/sqrt(N)) * cas(pi * (2n+1) * (2k+1) / (2N)),
    cas(t)  = cos(t) + sin(t),   k, n = 0..N-1.

The constants are computed in double precision and converted in VHDL to the
Q1.30 coefficient format (sfix_coef) with to_sfixed(<value>, 1, -30). Entries are classified according to the
complexity convention used for the proposed algorithms:

    0        - no operation
    +-1      - direct add/sub, no multiplier
    +-2^-k   - arithmetic shift_right, no multiplier
    other    - one multiplier per entry (constants are shared by value,
               products are not)

Pipeline: stage 1 registers all products/shifts, stage 2 registers the
output of a balanced adder tree per row. Total latency: 2 clocks.

Usage:
    python3 scripts/gen_naive.py            # generate N = 3..8
    python3 scripts/gen_naive.py 4 6        # generate selected N
    python3 scripts/gen_naive.py --report   # print operation counts only
"""

import os
import sys

from dht_common import ALL_N, EPS, REPO_ROOT, SEP, classify, dht_iv_matrix


def constant_names(N, C):
    """Map each distinct signed multiplier value to a constant name.

    Magnitudes are lettered A, B, C, ... in descending order; negative
    values get the suffix _NEG.
    """
    mags = []
    for row in C:
        for c in row:
            if classify(c)[0] == "mul" and not any(abs(abs(c) - m) < EPS for m in mags):
                mags.append(abs(c))
    mags.sort(reverse=True)

    names = {}
    for i, m in enumerate(mags):
        base = f"C_NAIVE_{N}_{chr(ord('A') + i)}"
        names[(i, +1)] = (base, m)
        names[(i, -1)] = (base + "_NEG", -m)

    def lookup(c):
        i = next(j for j, m in enumerate(mags) if abs(abs(c) - m) < EPS)
        return names[(i, 1 if c > 0 else -1)][0]

    return mags, names, lookup


def build_terms(N, C, lookup):
    """List of stage-1 terms per row: (index, vhdl expr, sign, comment)."""
    rows = []
    idx = 0
    for k in range(N):
        terms = []
        for n in range(N):
            c = C[k][n]
            kind, s = classify(c)
            if kind == "zero":
                continue
            if kind == "mul":
                expr = f"resize32({lookup(c)} * x({n}))"
                sign = +1
            elif kind == "shift":
                expr = f"resize32(shift_right(x({n}), {s}))"
                sign = 1 if c > 0 else -1
            else:
                expr = f"x({n})"
                sign = 1 if c > 0 else -1
            terms.append((idx, expr, sign, kind, f"c[{k}][{n}] = {c: .6f}"))
            idx += 1
        rows.append(terms)
    return rows, idx


def adder_tree(leaves):
    """Balanced pairwise reduction of signed leaves.

    leaves: list of (expr, sign). Returns (expr, sign, n_adders).
    A pair with one negative operand becomes a subtraction; a pair of two
    negative operands is summed and carries the negative sign upwards.
    """
    level = list(leaves)
    adders = 0
    while len(level) > 1:
        nxt = []
        for i in range(0, len(level) - 1, 2):
            (a, sa), (b, sb) = level[i], level[i + 1]
            if sa > 0 and sb > 0:
                nxt.append((f"add32({a}, {b})", +1))
            elif sa > 0:
                nxt.append((f"sub32({a}, {b})", +1))
            elif sb > 0:
                nxt.append((f"sub32({b}, {a})", +1))
            else:
                nxt.append((f"add32({a}, {b})", -1))
            adders += 1
        if len(level) % 2:
            nxt.append(level[-1])
        level = nxt
    expr, sign = level[0]
    return expr, sign, adders


def generate(N):
    C = dht_iv_matrix(N)
    mags, names, lookup = constant_names(N, C)
    rows, n_terms = build_terms(N, C, lookup)

    used = set()
    for terms in rows:
        for _, expr, _, kind, _ in terms:
            if kind == "mul":
                used.add(expr.split("(")[1].split(" ")[0])

    trees = []
    n_add = 0
    for k, terms in enumerate(rows):
        leaves = [(f"p({i})", sgn) if kind != "one" else (expr, sgn)
                  for i, expr, sgn, kind, _ in terms]
        expr, sign, a = adder_tree(leaves)
        if sign < 0:
            raise ValueError(f"N={N} row {k}: all terms negative, needs negation")
        trees.append(expr)
        n_add += a

    n_mul = sum(1 for t in rows for x in t if x[3] == "mul")
    n_shift = sum(1 for t in rows for x in t if x[3] == "shift")
    n_one = sum(1 for t in rows for x in t if x[3] == "one")
    n_zero = N * N - n_mul - n_shift - n_one
    counts = dict(mul=n_mul, add=n_add, shift=n_shift, one=n_one, zero=n_zero)

    # Stage-1 terms that are plain inputs (+-1 entries) are not registered
    # as products; they enter the adder tree directly from x.
    reg_terms = [(i, expr, cmt) for terms in rows for i, expr, _, kind, cmt in terms
                 if kind != "one"]

    L = []
    L += [SEP,
          f"-- n{N}_naive.vhd",
          "--",
          f"-- Naive implementation of the {N}-point DHT-IV:",
          f"-- direct matrix-vector multiplication Y = C({N}) * X.",
          "--"]
    for k in range(N):
        prefix = f"--   C({N}) = " if k == 0 else "--          "
        cells = [" 0     " if classify(c)[0] == "zero" else f"{c: .4f}" for c in C[k]]
        L.append((prefix + "  ".join(cells)).rstrip())
    L += ["--",
          "--   (values rounded for display only)",
          "--",
          "--   c[k][n] = (1/sqrt(N)) * cas(pi*(2n+1)*(2k+1)/(2N)),",
          "--   cas(t)  = cos(t) + sin(t),   k, n = 0..N-1",
          "--",
          "-- The normalization 1/sqrt(N) is folded into the constants. The",
          "-- constants are computed in double precision by scripts/gen_naive.py",
          "-- and converted to Q1.30 (sfix_coef) with to_sfixed(). This file is",
          "-- generated by that script - regenerate instead of editing by hand.",
          "--",
          "-- Arithmetic (same complexity convention as the proposed modules):",
          "--   0 entries      : no operation",
          "--   +-1 entries    : direct add/sub",
          "--   +-2^-k entries : arithmetic shift_right",
          "--   other entries  : one multiplier each; constants are shared by",
          "--                    value, products are not",
          f"--   Multipliers: {n_mul}, adders: {n_add}, shifts: {n_shift}",
          "--",
          "-- Pipeline:",
          "--      Stage 1: multiplications and shifts",
          "--      Stage 2: balanced adder tree per output",
          "--",
          "-- Total latency: 2 clocks",
          SEP,
          "library ieee;",
          "use ieee.std_logic_1164.all;",
          "use ieee.fixed_pkg.all;",
          "use work.fixed_types_pkg.all;",
          "",
          f"entity n{N}_naive is",
          "    port (",
          "        clk       : in  std_logic;",
          "        rst       : in  std_logic;",
          "        valid_in  : in  std_logic;",
          f"        x         : in  sfix32_vector(0 to {N - 1});",
          "        valid_out : out std_logic;",
          f"        y         : out sfix32_vector(0 to {N - 1})",
          "    );",
          f"end entity n{N}_naive;",
          "",
          f"architecture rtl of n{N}_naive is",
          ""]
    if mags:
        L.append(f"    -- Distinct coefficient values of C({N})")
        for i in range(len(mags)):
            for sgn in (+1, -1):
                name, v = names[(i, sgn)]
                if name in used:
                    L.append(f"    constant {name:<{len('C_NAIVE_N_X_NEG') + 1}}: sfix_coef := "
                             f"to_sfixed({v: .17f}, 1, -30);")
        L.append("")
    n_reg = len(reg_terms)
    if n_reg:
        L += [f"    signal p_int   : sfix32_vector(0 to {n_reg - 1});",
              f"    signal p       : sfix32_vector(0 to {n_reg - 1});"]
    L += ["    signal valid_1 : std_logic;",
          f"    signal y_int   : sfix32_vector(0 to {N - 1});",
          "",
          "begin",
          ""]

    # Re-index registered terms contiguously.
    remap = {}
    L.append("    -- Stage 1: multiplications and shifts")
    w = max(len(expr) for _, expr, _ in reg_terms) + 1
    for j, (i, expr, cmt) in enumerate(reg_terms):
        remap[i] = j
        lhs = f"p_int({j})"
        L.append(f"    {lhs:<9} <= {expr + ';':<{w}}  -- {cmt}")
    L.append("")
    L.append("    -- Stage 2: balanced adder tree per output")
    for k, expr in enumerate(trees):
        for i in sorted(remap, reverse=True):
            expr = expr.replace(f"p({i})", f"p(#{remap[i]})")
        expr = expr.replace("p(#", "p(")
        L.append(f"    y_int({k}) <= {expr};")
    L += ["",
          "    process (clk)",
          "    begin",
          "        if rising_edge(clk) then",
          "            -- Data registers are not reset, only the valid pipeline."]
    if n_reg:
        L.append("            p         <= p_int;")
    L += ["            y         <= y_int;",
          "            if rst = '1' then",
          "                valid_1   <= '0';",
          "                valid_out <= '0';",
          "            else",
          "                valid_1   <= valid_in;",
          "                valid_out <= valid_1;",
          "            end if;",
          "        end if;",
          "    end process;",
          "",
          "end architecture rtl;",
          ""]
    return "\n".join(L), counts


def main(argv):
    report_only = "--report" in argv
    Ns = [int(a) for a in argv if a.isdigit()] or list(ALL_N)
    print(f"{'N':>2} {'mul':>4} {'add':>4} {'shift':>5} {'+-1':>4} {'zero':>4}")
    for N in Ns:
        text, c = generate(N)
        print(f"{N:>2} {c['mul']:>4} {c['add']:>4} {c['shift']:>5} {c['one']:>4} {c['zero']:>4}")
        if not report_only:
            path = os.path.join(REPO_ROOT, "src", "naive", f"n{N}", f"n{N}_naive.vhd")
            with open(path, "w") as f:
                f.write(text)


if __name__ == "__main__":
    main(sys.argv[1:])
