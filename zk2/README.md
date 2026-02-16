# zk2

Zero-knowledge proofs using Circom and snarkjs — **hash list check** circuit with commitment chain (same workflow style as [zkBasics](../zkBasics/)).

## Overview

Prove knowledge of private values such that a **commitment** `cm_j = Poseidon(r_old, sn_produce, v)` equals the j-th element of a public list of 10 hashes, and `sn_consume = Poseidon(sn_produce, sk_old)` is satisfied — without revealing the private inputs.

- **Public inputs:** `hashes[10]` (list of 10 field elements), `sn_consume`.
- **Private inputs:** `v` (verifier challenge), `j` (index 0–9), `r_old`, `sk_old`, `rho`.
- **Public output:** `ok` = 1 when all circuit constraints hold.

Circuit uses **Poseidon** from circomlib (pk_old, sn_produce, sn_consume, cm_j chain).

## Project structure (lightweight — only source is committed)

```
zk2/
├── hash_preimage.circom       # Circuit: HashListCheckInternal(n) + Main(10)
├── input.json                 # Your input (hashes, sn_consume, v, j, r_old, sk_old, rho)
├── get_hash.js                # Helper: chain/single/random for building input.json
├── build.sh
├── setup_snarkjs.sh
├── prove.sh                   # Uses input.json
├── verify.sh
├── package.json
└── README.md
```

Generated (not committed; create with `npm install`, `./build.sh`, `./setup_snarkjs.sh`):
- `hash_preimage.r1cs`, `hash_preimage.sym`, `hash_preimage_js/` (WASM, witness script)
- `snarkjs/` (ptau, zkey, verification key)
- `prover/proof.json`, `prover/public.json` (after `./prove.sh`)

## Prerequisites

- [Circom](https://docs.circom.io/getting-started/installation/)
- [snarkjs](https://github.com/iden3/snarkjs) (npm global or in path)
- Node.js

## Workflow

### 1. Install & compile

```bash
cd zk2
npm install
./build.sh
```

### 2. Trusted setup (one-time)

```bash
./setup_snarkjs.sh
```

### 3. Edit `input.json`

Use a single **input.json** at the project root. Required fields:

| Field        | Public/Private | Description |
|-------------|----------------|-------------|
| `hashes`    | Public         | Array of 10 field elements (strings). Must satisfy `hashes[j] = Poseidon(r_old, sn_produce, v)`. |
| `sn_consume`| Public         | Field element; must equal `Poseidon(sn_produce, sk_old)` with `sn_produce = Poseidon(rho, Poseidon(sk_old))`. |
| `v`         | Private        | Verifier challenge (e.g. `"1"`). |
| `j`         | Private        | Index in 0–9 (string). |
| `r_old`     | Private        | Secret (string). |
| `sk_old`    | Private        | Secret (string). |
| `rho`       | Private        | Secret (string). |

**Generate a valid input** with the helper:

```bash
node get_hash.js chain <sk_old> <rho> <r_old> <v> <j>
# Example: node get_hash.js chain 12345 12345 13751379 1 3
# Output is valid input.json (hashes with cm_j at index j, rest zeros).
```

Other helpers:
- `node get_hash.js single <x>` — compute Poseidon(x).
- `node get_hash.js random` — print a random field element.

### 4. Prove

```bash
./prove.sh
```

Reads **input.json**, generates witness and proof → `prover/proof.json`, `prover/public.json`.

### 5. Verify

```bash
./verify.sh
```

## Circuit layout

In **hash_preimage.circom**:

- **HashListCheckInternal(n)** — private `v`, `j`, `r_old`, `sk_old`, `rho`; public `hashes[n]`, `sn_consume`. Computes pk_old, sn_produce, sn_consume, cm_j via Poseidon; constrains `sn_consume` and `hashes[j] === cm_j`; outputs `ok=1`.
- **Main(10)** — public `hashes[10]`, `sn_consume`; private `v`, `j`, `r_old`, `sk_old`, `rho`; public output `ok`.

## Files

| File | Purpose |
|------|---------|
| `hash_preimage.circom` | Circuit source |
| `input.json` | Input (hashes, sn_consume, v, j, r_old, sk_old, rho) |
| `get_hash.js` | Build input: `chain`, `single`, `random` |
| `build.sh` | Compile circuit |
| `setup_snarkjs.sh` | Trusted setup |
| `prove.sh` | Generate proof from input.json |
| `verify.sh` | Verify proof |

Verifier sees the proof, `ok=1`, and public inputs (hashes, sn_consume); private inputs stay hidden.
