#!/usr/bin/env bash
# Generate proof from input.json. Run from zk2/
# Edit input.json: hashes[10], sn_consume, and private v, j, r_old, sk_old, rho.
set -e

CIRCUIT=hash_preimage
INPUT=input.json

if [ ! -f "$INPUT" ]; then
  echo "Missing $INPUT. Required: hashes, sn_consume (public); v, j, r_old, sk_old, rho (private). See README."
  exit 1
fi

mkdir -p prover
echo "Using input: $INPUT"
echo "Generating witness..."
node hash_preimage_js/generate_witness.js hash_preimage_js/hash_preimage.wasm "$INPUT" hash_preimage_js/witness.wtns

echo "Creating proof..."
snarkjs groth16 prove snarkjs/${CIRCUIT}_0001.zkey hash_preimage_js/witness.wtns prover/proof.json prover/public.json

echo ""
echo "Proof saved to prover/proof.json"
echo "Public signal (ok): $(cat prover/public.json)"
echo "Verify: ./verify.sh"
