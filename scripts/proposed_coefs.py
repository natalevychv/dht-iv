"""
proposed_coefs.py

Coefficients of the proposed DHT-IV algorithms for N = 3..8.

COEFS[N] maps "S_k" to the value of the VHDL generic C_COEF_S_k_N of the
proposed modules, in generic order. Factors that are implemented as shifts
in VHDL (e.g. a/2 = 0.25 for N = 6) are not listed.

The base constants a, b, c, ... are entries of the first row of the DHT-IV
matrix, h[n] = c[0][n] = (1/sqrt(N)) * cas(pi * (2n+1) / (2N)). The formulas
follow the factorizations verified numerically outside this repository.
"""

from dht_common import dht_iv_matrix


def _n3():
    h = dht_iv_matrix(3)[0]
    a, b = h[2], h[1]
    return {
        "S_0": a,
        "S_1": b,
    }


def _n4():
    h = dht_iv_matrix(4)[0]
    a, b = h[0], h[2]
    return {
        "S_0": a - b,
        "S_1": -a - b,
        "S_2": b,
        "S_3": a - b,
        "S_4": -a - b,
        "S_5": b,
    }


def _n5():
    a, b, c, d, e = dht_iv_matrix(5)[0]
    return {
        "S_0": c,
        "S_1": c,
        "S_2": 0.25,
        "S_3": (a - b - d + e) / 4,
        "S_4": (a - b + d - e) / 2,
        "S_5": (-a - b + d + e) / 2,
        "S_6": (b - d) / 2,
    }


def _n6():
    h = dht_iv_matrix(6)[0]
    b = h[1]
    return {
        "S_1": b / 2,
        "S_2": b / 2,
        "S_3": b / 2,
        "S_4": b / 2,
    }


def _n7():
    a, b, c, d, e, f, g = dht_iv_matrix(7)[0]
    return {
        "S_0": d,
        "S_1": d,
        "S_2": (a - b + c + e - f + g) / 6,
        "S_3": (-b - c - e - f) / 2,
        "S_4": (a - c - e + g) / 2,
        "S_5": (-a + b + 2 * c + 2 * e + f - g) / 6,
        "S_6": (-a - b + c - e + f + g) / 6,
        "S_7": (-b - c + e + f) / 2,
        "S_8": (-a - c + e + g) / 2,
        "S_9": (a + b + 2 * c - 2 * e - f - g) / 6,
    }


def _n8():
    h = dht_iv_matrix(8)[0]
    a, b, c, d = h[0], h[1], h[4], h[5]
    return {
        "S_0": -a + b - c - d,
        "S_1": -a + b + c - d,
        "S_2": -b + d,
        "S_3": -a + b + c + d,
        "S_4": a + b + c + d,
        "S_5": -b - d,
        "S_6": a - b,
        "S_7": -b - c,
        "S_8": b,
        "S_9": -a + b + c + d,
        "S_10": a + b + c + d,
        "S_11": -b - d,
        "S_12": -a + b - c - d,
        "S_13": -a + b + c - d,
        "S_14": -b + d,
        "S_15": a - b,
        "S_16": -b - c,
        "S_17": b,
    }


COEFS = {N: f() for N, f in
         {3: _n3, 4: _n4, 5: _n5, 6: _n6, 7: _n7, 8: _n8}.items()}
