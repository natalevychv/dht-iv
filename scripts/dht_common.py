"""
dht_common.py

Definitions shared by the DHT-IV generator scripts (gen_naive.py, and later
the proposed-coefficient and test-vector generators).

    c[k][n] = (1/sqrt(N)) * cas(pi * (2n+1) * (2k+1) / (2N)),
    cas(t)  = cos(t) + sin(t),   k, n = 0..N-1.
"""

import math
import os

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ALL_N = range(3, 9)
EPS = 1e-12
SEP = "-" * 79


def dht_iv_matrix(N):
    """Full-precision DHT-IV matrix, normalization 1/sqrt(N) included."""
    C = []
    for k in range(N):
        row = []
        for n in range(N):
            t = math.pi * (2 * n + 1) * (2 * k + 1) / (2 * N)
            row.append((math.cos(t) + math.sin(t)) / math.sqrt(N))
        C.append(row)
    return C


def classify(c):
    """Return ('zero'|'one'|'shift'|'mul', shift amount or None)."""
    a = abs(c)
    if a < EPS:
        return "zero", None
    if abs(a - 1.0) < EPS:
        return "one", None
    for s in range(1, 16):
        if abs(a - 2.0 ** -s) < EPS:
            return "shift", s
    return "mul", None
