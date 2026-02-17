#!/usr/bin/env bash
# Trusted setup: Powers of Tau and circuit-specific keys. Run from zk2/ after ./build.sh
#
# Equivalent to Circom doc (with ptau in snarkjs/ and size 14 for this circuit):
#   snarkjs powersoftau new bn128 14 pot14_0000.ptau -v
#   snarkjs powersoftau contribute pot14_0000.ptau pot14_0001.ptau --name="First contribution" -v
#   snarkjs powersoftau prepare phase2 pot14_0001.ptau pot14_final.ptau -v
#   snarkjs groth16 setup zcash_pour.r1cs pot14_final.ptau zcash_pour_0000.zkey
#   snarkjs zkey contribute zcash_pour_0000.zkey zcash_pour_0001.zkey --name="Contributor" -v
#   snarkjs zkey export verificationkey zcash_pour_0001.zkey verification_key.json
set -e

CIRCUIT=zcash_pour
OUTPUT_DIR=snarkjs

mkdir -p "$OUTPUT_DIR"

if [ ! -f "$CIRCUIT.r1cs" ]; then
  echo "Error: $CIRCUIT.r1cs not found. Run ./build.sh first."
  exit 1
fi

# --- Powers of Tau (size 14: circuit needs it; 12 is too small) ---
PTAU_START="$OUTPUT_DIR/pot14_0000.ptau"
PTAU_CONTRIB="$OUTPUT_DIR/pot14_0001.ptau"
PTAU_FINAL="$OUTPUT_DIR/pot14_final.ptau"

echo "Step 1: Powers of Tau..."
snarkjs powersoftau new bn128 14 "$PTAU_START" -v
snarkjs powersoftau contribute "$PTAU_START" "$PTAU_CONTRIB" --name="First contribution" -v
snarkjs powersoftau prepare phase2 "$PTAU_CONTRIB" "$PTAU_FINAL" -v

# --- Circuit keys (zkey + verification key) ---
ZKEY_RAW="$OUTPUT_DIR/${CIRCUIT}_0000.zkey"
ZKEY_FINAL="$OUTPUT_DIR/${CIRCUIT}_0001.zkey"
VERIFICATION_KEY="$OUTPUT_DIR/${CIRCUIT}_verification_key.json"

echo "Step 2: Circuit zkey and verification key..."
snarkjs groth16 setup "$CIRCUIT.r1cs" "$PTAU_FINAL" "$ZKEY_RAW"
snarkjs zkey contribute "$ZKEY_RAW" "$ZKEY_FINAL" --name="Contributor" -v -e="$(openssl rand -hex 32)"
snarkjs zkey export verificationkey "$ZKEY_FINAL" "$VERIFICATION_KEY"

echo ""
echo "Setup complete. Proving key: $ZKEY_FINAL"
echo "Verify later: ./verify.sh"
