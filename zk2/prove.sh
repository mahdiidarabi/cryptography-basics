#!/usr/bin/env bash
# Generate proof from input.json. Run from zk2/
# input.json must include: hashes, sn_consume (public); v, j, r_old, sk_old, rho; r1, rho1, v1, pk1, r2, rho2, v2, pk2 (pour). v = v1 + v2.
set -e

CIRCUIT=zcash_pour
INPUT=input.json

if [ ! -f "$INPUT" ]; then
  echo "Missing $INPUT. Required: hashes, sn_consume, v, j, r_old, sk_old, rho, r1, rho1, v1, pk1, r2, rho2, v2, pk2 (v = v1 + v2). See README or: node get_hash.js chain ..."
  exit 1
fi

mkdir -p prover
echo "Using input: $INPUT"
echo "Generating witness..."
node zcash_pour_js/generate_witness.js zcash_pour_js/zcash_pour.wasm "$INPUT" zcash_pour_js/witness.wtns

echo "Creating proof..."
snarkjs groth16 prove snarkjs/${CIRCUIT}_0001.zkey zcash_pour_js/witness.wtns prover/proof.json prover/public.json

echo ""
echo "Proof saved to prover/proof.json"
echo "Public outputs (cm1, cm2, ok): $(cat prover/public.json)"
echo "Verify: ./verify.sh"
