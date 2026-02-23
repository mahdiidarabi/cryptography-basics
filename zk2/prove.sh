#!/usr/bin/env bash
# Generate witness and Groth16 proof. Run from zk2/
#
# Docs:
#   https://docs.circom.io/getting-started/computing-the-witness/
#   https://docs.circom.io/getting-started/proving-circuits/
#
# Computing the witness (doc):
#   node generate_witness.js multiplier2.wasm input.json witness.wtns
#   (run from multiplier2_js/; input.json has inputs in JSON, e.g. {"a":"3","b":"11"})
#
# Generating a proof (doc):
#   snarkjs groth16 prove multiplier2_0001.zkey witness.wtns proof.json public.json
#
# Here: input from input.json or input_zcash_pour.json; proof/public written to prover/
set -e

CIRCUIT=zcash_pour
WITNESS_DIR="${CIRCUIT}_js"
PROVER_DIR=prover
SNARKJS_DIR=snarkjs

# Use input.json by default; fall back to input_zcash_pour.json if you use that name
if [ -f "input.json" ]; then
  INPUT_FILE=input.json
elif [ -f "input_zcash_pour.json" ]; then
  INPUT_FILE=input_zcash_pour.json
else
  echo "Error: No input file found. Create input.json or input_zcash_pour.json (see README)."
  exit 1
fi

mkdir -p "$PROVER_DIR"

if [ ! -f "$WITNESS_DIR/$CIRCUIT.wasm" ]; then
  echo "Error: $WITNESS_DIR/$CIRCUIT.wasm not found. Run ./build.sh first."
  exit 1
fi
if [ ! -f "$SNARKJS_DIR/${CIRCUIT}_0001.zkey" ]; then
  echo "Error: $SNARKJS_DIR/${CIRCUIT}_0001.zkey not found. Run ./setup_snarkjs.sh first."
  exit 1
fi

# Generate witness (doc: generate_witness.js wasm input.json witness.wtns)
echo "Generating witness from $INPUT_FILE..."
node "$WITNESS_DIR/generate_witness.js" "$WITNESS_DIR/$CIRCUIT.wasm" "$INPUT_FILE" "$WITNESS_DIR/witness.wtns"

# Generate proof (doc: groth16 prove zkey witness.wtns proof.json public.json)
echo "Creating proof..."
snarkjs groth16 prove "$SNARKJS_DIR/${CIRCUIT}_0001.zkey" "$WITNESS_DIR/witness.wtns" "$PROVER_DIR/proof.json" "$PROVER_DIR/public.json"

echo ""
echo "Proof: $PROVER_DIR/proof.json"
echo "Public: $PROVER_DIR/public.json"
echo "Verify: ./verify.sh"
