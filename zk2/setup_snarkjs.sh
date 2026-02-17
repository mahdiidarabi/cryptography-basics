#!/usr/bin/env bash
# Trusted setup: Powers of Tau and circuit-specific keys. Run from zk2/ after ./build.sh
set -e

CIRCUIT=zcash_pour
OUTPUT_DIR=snarkjs

# Create directory for keys and ptau files
mkdir -p "$OUTPUT_DIR"

# Need the compiled circuit first
if [ ! -f "$CIRCUIT.r1cs" ]; then
  echo "Error: $CIRCUIT.r1cs not found. Run ./build.sh first."
  exit 1
fi

# --- Step 1: Powers of Tau (same for any circuit of this size) ---
# We use size 14 (2^14) because this circuit needs it. Size 12 is too small.
PTAU_START="$OUTPUT_DIR/pot14_0000.ptau"
PTAU_CONTRIB="$OUTPUT_DIR/pot14_0001.ptau"
PTAU_FINAL="$OUTPUT_DIR/pot14_final.ptau"

echo "Step 1: Powers of Tau (this may take a few minutes)..."
snarkjs powersoftau new bn128 14 "$PTAU_START" -v
snarkjs powersoftau contribute "$PTAU_START" "$PTAU_CONTRIB" --name="First contribution" -v
snarkjs powersoftau prepare phase2 "$PTAU_CONTRIB" "$PTAU_FINAL" -v
echo "Step 1 done."

# --- Step 2: Circuit-specific proving and verification keys ---
ZKEY_RAW="$OUTPUT_DIR/${CIRCUIT}_0000.zkey"
ZKEY_FINAL="$OUTPUT_DIR/${CIRCUIT}_0001.zkey"
VERIFICATION_KEY="$OUTPUT_DIR/${CIRCUIT}_verification_key.json"

echo "Step 2: Circuit keys (zkey)..."
snarkjs groth16 setup "$CIRCUIT.r1cs" "$PTAU_FINAL" "$ZKEY_RAW"
snarkjs zkey contribute "$ZKEY_RAW" "$ZKEY_FINAL" --name="Contributor" -v -e="$(openssl rand -hex 32)"
snarkjs zkey export verificationkey "$ZKEY_FINAL" "$VERIFICATION_KEY"
echo "Step 2 done."

echo ""
echo "Setup complete. Use $ZKEY_FINAL for proving."
echo "To verify later: ./verify.sh"
