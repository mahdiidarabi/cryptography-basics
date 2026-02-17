#!/usr/bin/env bash
# Verify proof. Run from zk2/
#
# Equivalent to Circom doc (files in snarkjs/ and prover/):
#   snarkjs groth16 verify verification_key.json public.json proof.json
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
