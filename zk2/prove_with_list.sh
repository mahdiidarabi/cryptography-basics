#!/usr/bin/env bash
# Prove you know a secret whose hash is among 10 hashes (9 from file + your secret's hash).
# Usage: ./prove_with_list.sh <secret> [others.json]
# Default others file: other_hashs.json
set -e

SECRET=$1
if [ -z "$SECRET" ]; then
  echo "Usage: ./prove_with_list.sh <secret> [others.json]"
  exit 1
fi

OTHERS=${2:-other_hashs.json}
CIRCUIT=hash_preimage

echo "Building input: 9 hashes from $OTHERS + Poseidon(secret) at index 9..."
node get_input_with_others.js "$SECRET" "$OTHERS" > hash_preimage_js/input.json

echo "Generating witness..."
node hash_preimage_js/generate_witness.js hash_preimage_js/hash_preimage.wasm hash_preimage_js/input.json hash_preimage_js/witness.wtns

echo "Creating proof..."
snarkjs groth16 prove snarkjs/${CIRCUIT}_0001.zkey hash_preimage_js/witness.wtns prover/proof.json prover/public.json

echo ""
echo "Proof saved to prover/proof.json"
echo "Verify: ./verify.sh"
