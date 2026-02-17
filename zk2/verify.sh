#!/usr/bin/env bash
# Verify a proof. Run from zk2/
# Expects: snarkjs/ (verification key), prover/ (proof and public signals).
set -e

CIRCUIT=zcash_pour
PROVER_DIR=prover
SNARKJS_DIR=snarkjs

# Create prover directory if missing (so user knows where to put files)
mkdir -p "$PROVER_DIR"

# Check required files exist
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

# Verify
snarkjs groth16 verify "$SNARKJS_DIR/${CIRCUIT}_verification_key.json" "$PROVER_DIR/public.json" "$PROVER_DIR/proof.json"

echo "Verification passed."
