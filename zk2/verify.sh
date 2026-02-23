#!/usr/bin/env bash
# Verify Groth16 proof. Run from zk2/
#
# Doc: https://docs.circom.io/getting-started/proving-circuits/
#
# Verifying a proof (doc):
#   snarkjs groth16 verify verification_key.json public.json proof.json
# Output: OK if valid. Uses verification_key.json, proof.json, public.json.
#
# Here: verification key from snarkjs/, proof and public from prover/
set -e

CIRCUIT=zcash_pour
PROVER_DIR=prover
SNARKJS_DIR=snarkjs

mkdir -p "$PROVER_DIR"

if [ ! -f "$SNARKJS_DIR/${CIRCUIT}_verification_key.json" ]; then
  echo "Error: $SNARKJS_DIR/${CIRCUIT}_verification_key.json not found. Run ./setup_snarkjs.sh first."
  exit 1
fi
if [ ! -f "$PROVER_DIR/public.json" ]; then
  echo "Error: $PROVER_DIR/public.json not found. Run ./prove.sh first."
  exit 1
fi
if [ ! -f "$PROVER_DIR/proof.json" ]; then
  echo "Error: $PROVER_DIR/proof.json not found. Run ./prove.sh first."
  exit 1
fi

snarkjs groth16 verify "$SNARKJS_DIR/${CIRCUIT}_verification_key.json" "$PROVER_DIR/public.json" "$PROVER_DIR/proof.json"

echo "Verification passed."
