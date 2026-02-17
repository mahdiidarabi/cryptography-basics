# zk2 — Zcash-style pour circuit

Zero-knowledge proof built with **Circom** and **snarkjs**. The circuit combines a **spending proof** (you know a note that appears in a list of commitments) with a **pour** (you split a value into two new commitments without revealing the amounts).

---

## What the circuit proves

1. **Spending:** You know private data (`v`, `j`, `r_old`, `sk_old`, `rho`) such that:
   - `sn_consume = hash(sn_produce || sk_old)` with `sn_produce = hash(rho || hash(sk_old))`
   - The commitment `hash(r_old || sn_produce || v)` equals `hashes[j]` (the j‑th entry of a public list of 10 hashes).

2. **Pour:** You know two output notes such that:
   - Total value is preserved: `v = v1 + v2` (with v1, v2 non‑negative).
   - Public outputs `cm1` and `cm2` are the correct commitments for the two notes.

**Public inputs:** `hashes[10]`, `sn_consume`  
**Public outputs:** `cm1`, `cm2`, `ok`  
**Private:** `v`, `j`, `r_old`, `sk_old`, `rho`, and pour fields `r1`, `rho1`, `v1`, `pk1`, `r2`, `rho2`, `v2`, `pk2`.

---

## Project structure

**Source (committed):**

```
zk2/
├── zcash_pour.circom    # Circuit: SpendingCircuit + PourCircuit
├── input.json           # Witness input (edit or generate with get_hash.js)
├── get_hash.js          # Helpers to build/fix input.json
├── build.sh             # Compile circuit
├── setup_snarkjs.sh     # Trusted setup (Powers of Tau + zkey)
├── prove.sh             # Generate proof from input.json
├── verify.sh            # Verify proof
├── package.json
├── .gitignore
└── README.md
```

**Generated (not committed; created when you run the scripts):**

```
zk2/
├── zcash_pour.r1cs           # From build.sh
├── zcash_pour.sym
├── zcash_pour_js/             # From build.sh (WASM + witness generator)
│   ├── zcash_pour.wasm
│   ├── generate_witness.js
│   └── witness.wtns          # From prove.sh
├── snarkjs/                   # From setup_snarkjs.sh
│   ├── pot14_*.ptau
│   ├── zcash_pour_0001.zkey
│   └── zcash_pour_verification_key.json
└── prover/                    # From prove.sh
    ├── proof.json
    └── public.json
```

---

## Prerequisites

- **Circom** — [install](https://docs.circom.io/getting-started/installation/)
- **snarkjs** — `npm install -g snarkjs` or in PATH
- **Node.js** — for witness generation and `get_hash.js`

---

## How to run

All commands are run from the **zk2/** directory.

### 1. Install dependencies

```bash
cd zk2
npm install
```

### 2. Build the circuit

```bash
./build.sh
```

This compiles `zcash_pour.circom` and creates `zcash_pour.r1cs`, `zcash_pour.sym`, and `zcash_pour_js/`.

### 3. Run the trusted setup

```bash
./setup_snarkjs.sh
```

Runs Powers of Tau (2^14) and generates the proving/verification keys in `snarkjs/`. May take a few minutes the first time.

### 4. Prepare input.json

You need a valid `input.json` with all spending and pour fields. **Constraint:** `v = v1 + v2` (v1 and v2 non‑negative).

**Option A — generate a full valid input:**

```bash
node get_hash.js chain <sk_old> <rho> <r_old> <v> <j> [v1]
```

Example (v=5, v1=2, v2=3):

```bash
node get_hash.js chain 12345 12345 13751379 5 3 2 > input.json
```

**Option B — fix an existing input.json** (recomputes hashes and sn_consume so the circuit is satisfied):

```bash
node get_hash.js complete-input input.json --write
```

**Option C — edit input.json by hand.** Use `node get_hash.js from-input input.json` to print the correct `hashes[j]` and `sn_consume` to paste in.

### 5. Generate the proof

```bash
./prove.sh
```

Reads `input.json`, generates the witness, then the proof. Writes `prover/proof.json` and `prover/public.json`.

### 6. Verify the proof

```bash
./verify.sh
```

Checks the proof against the verification key and public inputs/outputs. Prints “Verification passed.” on success.

---

## input.json fields

| Field        | Role     | Description |
|-------------|----------|-------------|
| `hashes`    | Public   | Array of 10 field elements (strings). Must satisfy spending constraint for `j`. |
| `sn_consume`| Public   | Serial number (consumed note). Must equal `hash(sn_produce \|\| sk_old)`. |
| `v`         | Private  | Total value (e.g. `"5"`). |
| `j`         | Private  | Index in 0–9 for which `hashes[j]` is the commitment. |
| `r_old`     | Private  | Randomness for the spent note. |
| `sk_old`    | Private  | Secret key for the spent note. |
| `rho`       | Private  | Randomness for sn_produce. |
| `r1`, `rho1`, `v1`, `pk1` | Private | First new note (randomness, value, public key). |
| `r2`, `rho2`, `v2`, `pk2` | Private | Second new note. **Must have** `v1 + v2 = v`. |

---

## get_hash.js commands

| Command | Purpose |
|--------|--------|
| `chain <sk_old> <rho> <r_old> <v> <j> [v1]` | Print a full valid input (v1+v2=v; default v1=2). |
| `from-input [input.json]` | Print `hashes[j]` and `sn_consume` (and sn_produce) to paste into input.json. |
| `complete-input [input.json] [--write]` | Recompute spending fields; with `--write`, overwrites the file. Use if witness fails. |
| `single <x>` | Compute Poseidon(x). |
| `random` | Print a random field element. |

---

## Scripts summary

| Script            | What it does |
|-------------------|--------------|
| `./build.sh`      | Compile `zcash_pour.circom` → R1CS, WASM, `zcash_pour_js/`. |
| `./setup_snarkjs.sh` | Powers of Tau + zkey + verification key in `snarkjs/`. |
| `./prove.sh`      | Build witness from `input.json`, then create proof → `prover/`. |
| `./verify.sh`     | Verify `prover/proof.json` using `snarkjs/` and `prover/public.json`. |

If the witness step fails (e.g. “Assert Failed”), run `node get_hash.js complete-input input.json --write` so that `hashes` and `sn_consume` match your private inputs, then run `./prove.sh` again.
