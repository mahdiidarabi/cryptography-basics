#!/usr/bin/env bash
# Generate proof: prove knowledge of r,j where Poseidon(r) == hashes[j]. Run from zk2/
# Usage: ./prove.sh [r] [j]
# Default: r=12345, j=0
set -e

R=${1:-12345}
J=${2:-0}
CIRCUIT=hash_preimage

# Generate input with hashes[j] = Poseidon(r)
echo "Generating input: r=$R, j=$J, hashes[j]=Poseidon(r)..."
node get_input.js "$R" "$J" > hash_preimage_js/input.json

# Generate witness
echo "Generating witness..."
node hash_preimage_js/generate_witness.js hash_preimage_js/hash_preimage.wasm hash_preimage_js/input.json hash_preimage_js/witness.wtns

# Generate proof
echo "Creating proof..."
snarkjs groth16 prove snarkjs/${CIRCUIT}_0001.zkey hash_preimage_js/witness.wtns prover/proof.json prover/public.json

echo ""
echo "Proof saved to prover/proof.json"
echo "Public signal (ok): $(cat prover/public.json)"
echo "Verify: snarkjs groth16 verify snarkjs/hash_preimage_verification_key.json prover/public.json prover/proof.json"
