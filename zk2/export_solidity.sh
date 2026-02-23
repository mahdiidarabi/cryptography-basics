#!/usr/bin/env bash
# Export Solidity verifier and calldata. Run from zk2/ after ./prove.sh
#
# Creates in prover/:
#   verifier.sol   — Groth16 verifier contract
#   calldata.json  — proof + public inputs as JSON (for verify() calldata)
set -e

CIRCUIT=zcash_pour
ZKEY="snarkjs/${CIRCUIT}_0001.zkey"
PROVER_DIR=prover

mkdir -p "$PROVER_DIR"

if [ ! -f "$ZKEY" ]; then
  echo "Error: $ZKEY not found. Run ./setup_snarkjs.sh first."
  exit 1
fi
if [ ! -f "$PROVER_DIR/proof.json" ] || [ ! -f "$PROVER_DIR/public.json" ]; then
  echo "Error: $PROVER_DIR/proof.json and/or $PROVER_DIR/public.json not found. Run ./prove.sh first."
  exit 1
fi

echo "[INFO] Exporting Solidity verifier to $PROVER_DIR/verifier.sol"
snarkjs zkey export solidityverifier "$ZKEY" "$PROVER_DIR/verifier.sol"

echo "[INFO] Generating calldata (proof + public inputs) -> $PROVER_DIR/calldata.json"
cd "$PROVER_DIR"
snarkjs generatecall > calldata.json
cd - > /dev/null

echo "[INFO] Done. Files in $PROVER_DIR/: verifier.sol, calldata.json"
