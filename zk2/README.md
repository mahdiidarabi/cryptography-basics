# zk2

Zero-knowledge proofs using Circom and snarkjs — **Hash list check** circuit (same workflow style as [zkBasics](../zkBasics/)).

## Overview

Prove you know `r` and `j` such that **Poseidon(r) equals the j'th hash** in a public list of 10 hashes, without revealing `r` or `j`.

- **Private inputs:** `r` (preimage), `j` (index 0–9).
- **Public input:** `hashes[10]` (list of 10 hashes).
- **Public output:** `ok` = 1 when Poseidon(r) = hashes[j].

Circuit uses **Poseidon** from circomlib.

## Project structure (lightweight — only source is committed)

```
zk2/
├── hash_preimage.circom       # Circuit: HashListCheckInternal(n) + Main(10)
├── input.json                 # Your input (hashes, r, j) — edit this
├── get_hash.js                # Optional: compute Poseidon(secret) or random
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

Use a single **input.json** at the project root. Format:

```json
{
  "hashes": ["0", "0", "0", "<Poseidon(r)>", "0", "0", "0", "0", "0", "0"],
  "r": "42",
  "j": "3"
}
```

- `hashes`: array of 10 field elements (strings). Must satisfy **hashes[j] = Poseidon(r)**.
- `r`: secret preimage (string).
- `j`: index in 0–9 (string).

You can set 9 entries to `"0"` and put `Poseidon(r)` at index `j`, or use any 10 hashes as long as the j-th equals Poseidon(r).

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

- **HashListCheckInternal(n)** — private `r`, `j`; public `hashes[n]`; constrains Poseidon(r) = hashes[j] via selectors; outputs `ok=1`.
- **Main(10)** — public `hashes[10]`, private `r`, `j`; public output `ok`.

## Files

| File | Purpose |
|------|---------|
| `hash_preimage.circom` | Circuit source |
| `input.json` | Input (hashes, r, j) — single place to edit |
| `build.sh` | Compile circuit |
| `setup_snarkjs.sh` | Trusted setup |
| `prove.sh` | Generate proof from input.json |
| `verify.sh` | Verify proof |

Verifier sees the proof and `ok=1`; they do not see `r` or `j`.
