# zk2

Zero-knowledge proofs with Circom and snarkjs — **zcash_pour** circuit: spending proof + pour (split value, commitments).

**Prove:** (1) You know private `v`, `j`, `r_old`, `sk_old`, `rho` such that `sn_consume = hash(sn_produce || sk_old)` and `hashes[j] = hash(r_old || sn_produce || v)`; (2) You know pour inputs such that `v = v1 + v2` (v1, v2 non-negative) and outputs `cm1`, `cm2` are the corresponding commitments.

- **Public inputs:** `hashes[10]`, `sn_consume`. **Public outputs:** `cm1`, `cm2`, `ok`.
- **Private:** `v`, `j`, `r_old`, `sk_old`, `rho`, `r1`, `rho1`, `v1`, `pk1`, `r2`, `rho2`, `v2`, `pk2` (with `v = v1 + v2`).

## Structure (lightweight)

```
zk2/
├── zcash_pour.circom   # Circuit (SpendingCircuit + PourCircuit)
├── input.json          # Full input (see below)
├── get_hash.js         # Helpers for input.json
├── build.sh, setup_snarkjs.sh, prove.sh, verify.sh
└── package.json
```

Generated (not committed): `zcash_pour.r1cs`, `zcash_pour_js/`, `snarkjs/`, `prover/*.json`.

## input.json

Required fields:

- **Spending:** `hashes` (10), `sn_consume`, `v`, `j`, `r_old`, `sk_old`, `rho`
- **Pour:** `r1`, `rho1`, `v1`, `pk1`, `r2`, `rho2`, `v2`, `pk2` — must satisfy **v = v1 + v2** (v1, v2 non-negative).

Use helpers to build or fix:

```bash
node get_hash.js chain <sk_old> <rho> <r_old> <v> <j> [v1]   # full valid input (default v1=2 if v=5)
node get_hash.js from-input input.json                        # hashes[j], sn_consume, sn_produce
node get_hash.js complete-input input.json --write             # fill/fix all fields in place
```

Then:

```bash
./prove.sh && ./verify.sh
```

## get_hash.js

| Command | Purpose |
|--------|--------|
| `from-input [input.json]` | Print `hashes[j]` (stdout), `sn_consume`, `sn_produce` (stderr) |
| `complete-input [input.json] [--write]` | Full input with spending + pour fields; `--write` overwrites file |
| `chain <sk_old> <rho> <r_old> <v> <j> [v1]` | Full valid input (v1+v2=v; default v1=2) |
| `single <x>`, `random` | Poseidon(x) or random field element |

## Prerequisites

Circom, snarkjs, Node.js.
