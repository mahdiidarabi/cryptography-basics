#!/usr/bin/env bash
# Generate proof from hash_preimage_js/input.json. Run from zk2/
# Edit hash_preimage_js/input.json (hashes, r, j) so that hashes[j] = Poseidon(r).
set -e

CIRCUIT=hash_preimage
INPUT=input.json

if [ ! -f "$INPUT" ]; then
  echo "Missing $INPUT. Create it with: {\"hashes\": [10 field elements], \"r\": \"<secret>\", \"j\": \"<0..9>\"}"
  exit 1
fi

echo "Using input: $INPUT"
echo "Generating witness..."
node hash_preimage_js/generate_witness.js hash_preimage_js/hash_preimage.wasm "$INPUT" hash_preimage_js/witness.wtns

echo "Creating proof..."
snarkjs groth16 prove snarkjs/${CIRCUIT}_0001.zkey hash_preimage_js/witness.wtns prover/proof.json prover/public.json

echo ""
echo "Proof saved to prover/proof.json"
echo "Public signal (ok): $(cat prover/public.json)"
echo "Verify: ./verify.sh"
