#!/usr/bin/env bash
# Generate a proof from input.json. Run from zk2/
# input.json must contain all circuit inputs (see README). Ensure v = v1 + v2.
set -e

CIRCUIT=zcash_pour
INPUT_FILE=input.json
WITNESS_DIR="${CIRCUIT}_js"
PROVER_DIR=prover
SNARKJS_DIR=snarkjs

# Create prover directory so we can write proof and public signals there
mkdir -p "$PROVER_DIR"

# Check input file exists
if [ ! -f "$INPUT_FILE" ]; then
  echo "Error: $INPUT_FILE not found."
  echo "Create it (see README) or run: node get_hash.js chain <sk_old> <rho> <r_old> <v> <j> [v1]"
  exit 1
fi

# Check we have the compiled circuit and keys
if [ ! -f "$WITNESS_DIR/$CIRCUIT.wasm" ]; then
  echo "Error: $WITNESS_DIR/$CIRCUIT.wasm not found. Run ./build.sh first."
  exit 1
fi
if [ ! -f "$SNARKJS_DIR/${CIRCUIT}_0001.zkey" ]; then
  echo "Error: $SNARKJS_DIR/${CIRCUIT}_0001.zkey not found. Run ./setup_snarkjs.sh first."
  exit 1
fi

# Generate witness from input
echo "Generating witness from $INPUT_FILE..."
node "$WITNESS_DIR/generate_witness.js" "$WITNESS_DIR/$CIRCUIT.wasm" "$INPUT_FILE" "$WITNESS_DIR/witness.wtns"

# Generate proof
echo "Creating proof..."
snarkjs groth16 prove "$SNARKJS_DIR/${CIRCUIT}_0001.zkey" "$WITNESS_DIR/witness.wtns" "$PROVER_DIR/proof.json" "$PROVER_DIR/public.json"

echo ""
echo "Proof saved to $PROVER_DIR/proof.json"
echo "Public outputs saved to $PROVER_DIR/public.json"
echo "To verify: ./verify.sh"
