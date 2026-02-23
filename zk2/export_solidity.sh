#!/usr/bin/env bash
# Export Solidity verifier and calldata for on-chain verification. Run from zk2/ after ./prove.sh
#
# Doc: https://docs.circom.io/getting-started/proving-circuits/ (Verifying from a Smart Contract)
#
# Export verifier (doc):
#   snarkjs zkey export solidityverifier multiplier2_0001.zkey verifier.sol
#
# Generate call parameters for verifyProof (doc):
#   snarkjs generatecall
#   (run from directory containing proof.json and public.json; paste output into Remix)
#
# Here: verifier.sol and calldata.json are written to prover/
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
