# zk2

Zero-knowledge proofs with Circom and snarkjs — hash list check + commitment chain (style of [zkBasics](../zkBasics/)).

**Prove:** you know private `v`, `j`, `r_old`, `sk_old`, `rho` such that `sn_consume = hash(sn_produce || sk_old)` and `hashes[j] = hash(r_old || sn_produce || v)` (with `sn_produce = hash(rho || hash(sk_old))`), without revealing them.

- **Public:** `hashes[10]`, `sn_consume`. **Private:** `v`, `j`, `r_old`, `sk_old`, `rho`. **Output:** `ok` = 1.

## Structure (lightweight)

```
zk2/
├── hash_preimage.circom   # Circuit
├── input.json             # Input (hashes, sn_consume, v, j, r_old, sk_old, rho)
├── get_hash.js            # Helpers for input.json
├── build.sh, setup_snarkjs.sh, prove.sh, verify.sh
└── package.json
```

Generated (not committed): `hash_preimage.r1cs`, `hash_preimage_js/`, `snarkjs/`, `prover/*.json` — create with `npm install`, `./build.sh`, `./setup_snarkjs.sh`.

## Workflow

```bash
npm install && ./build.sh && ./setup_snarkjs.sh
```

Edit **input.json** (or generate one):

```bash
node get_hash.js chain <sk_old> <rho> <r_old> <v> <j>   # full valid input
node get_hash.js from-input input.json                  # hashes[j], sn_consume, sn_produce to paste
node get_hash.js complete-input input.json --write     # fill sn_consume + hashes[j] in place
```

Then:

```bash
./prove.sh && ./verify.sh
```

## get_hash.js

| Command | Purpose |
|--------|--------|
| `from-input [input.json]` | Print value for `hashes[j]` (stdout) and `sn_consume`, `sn_produce` (stderr) to paste into input.json |
| `complete-input [input.json] [--write]` | Print or write full input with `sn_consume` and `hashes[j]` set |
| `chain <sk_old> <rho> <r_old> <v> <j>` | Print full valid input.json |
| `single <x>`, `random` | Poseidon(x) or random field element |

## Prerequisites

Circom, snarkjs, Node.js.
