# zk2

Zero-knowledge proofs using circom and snarkjs.

## Hash preimage proof

Prove you know `r` and `j` such that **Poseidon(r) equals the j'th hash** in a public list of 10 hashes — without revealing `r` or `j`.

### Idea

- **Private inputs:** `r` (preimage), `j` (index 0–9).
- **Public input:** `hashes[10]` (list of 10 hashes).
- **Public output:** `1` (true) if Poseidon(r) = hashes[j], else `0` (false).

The circuit uses **Poseidon** from circomlib (ZK-friendly, same field as the curve).

### Quick start

```bash
cd zk2
npm install
./build.sh
./setup_snarkjs.sh
./prove.sh 12345 3
./verify.sh
```

### Step by step

#### 1. Install & compile

```bash
cd zk2
npm install
./build.sh
```

Or manually:

```bash
circom hash_preimage.circom --r1cs --wasm --sym -o . -l node_modules
```

#### 2. Trusted setup (powers of tau + zkey)

```bash
./setup_snarkjs.sh
```

Uses existing `snarkjs/pot12_final.ptau` from the multiplier, or downloads Hermez pot12.

#### 3. Prove

```bash
./prove.sh [r] [j]
# default: r=12345, j=0
```

- Builds a list of 10 hashes with `hashes[j] = Poseidon(r)` via circomlibjs
- Generates witness and Groth16 proof
- Output: `prover/proof.json`, `prover/public.json` (public output: ok = 1)

#### 4. Verify

```bash
./verify.sh
```

Checks the proof against the public output (ok = 1).

### Generate input for custom r and j

```bash
node get_input.js 12345 3
# Outputs JSON: { hashes, r, j } with hashes[j] = Poseidon(r)
```

Or create `hash_preimage_js/input.json` manually:

```json
{
  "hashes": ["0", "0", "0", "<Poseidon(r)>", "0", "0", "0", "0", "0", "0"],
  "r": "42",
  "j": "3"
}
```

### Prove with a list of 9 other hashes

If you have 9 hashes in `other_hashs.json` and want to prove your secret's hash is among the 10 (9 + yours):

```bash
./prove_with_list.sh <your_secret> [others.json]
# Default others file: other_hashs.json
./verify.sh
```

### Files

| File | Purpose |
|------|---------|
| `hash_preimage.circom` | Circuit: Main(10), Poseidon(r) == hashes[j] → ok=1 |
| `get_input.js` | Build input with hashes[j] = Poseidon(r) |
| `get_input_with_others.js` | Build input from 9 hashes in file + secret |
| `prove_with_list.sh` | Prove with other_hashs.json + your secret |
| `build.sh` | Compile circuit |
| `setup_snarkjs.sh` | Trusted setup (ptau, zkey) |
| `prove.sh` | Generate proof |
| `verify.sh` | Verify proof |

Verifier sees the proof and ok=1; they never see `r` or `j`.
