#!/usr/bin/env bash
# Trusted setup for hash_preimage: Powers of Tau + Phase 2 (per circuit).
# Run from zk2/ after ./build.sh (hash_preimage.r1cs must exist).
# Follows https://docs.circom.io/getting-started/proving-circuits/
set -e

CIRCUIT=hash_preimage
DIR=snarkjs
mkdir -p "$DIR"

if [ ! -f "${CIRCUIT}.r1cs" ]; then
  echo "Missing ${CIRCUIT}.r1cs. Run ./build.sh first."
  exit 1
fi

# --- Powers of Tau (circuit-independent) ---
# Always run the ceremony so we get a valid bn128 ptau (avoids reusing old/invalid downloads).
PTAU0="${DIR}/pot12_0000.ptau"
PTAU1="${DIR}/pot12_0001.ptau"
PTAU_FINAL="${DIR}/pot12_final.ptau"

echo "Powers of Tau: starting ceremony..."
snarkjs powersoftau new bn128 12 "$PTAU0" -v
echo "Powers of Tau: contributing..."
snarkjs powersoftau contribute "$PTAU0" "$PTAU1" --name="First contribution" -v
echo "Powers of Tau: preparing phase2..."
snarkjs powersoftau prepare phase2 "$PTAU1" "$PTAU_FINAL" -v
echo "Powers of Tau: done."

# --- Phase 2 (circuit-specific) ---
ZKEY0="${DIR}/${CIRCUIT}_0000.zkey"
ZKEY1="${DIR}/${CIRCUIT}_0001.zkey"

echo "Phase 2: circuit-specific setup (zkey)..."
snarkjs groth16 setup ${CIRCUIT}.r1cs "$PTAU_FINAL" "$ZKEY0"
snarkjs zkey contribute "$ZKEY0" "$ZKEY1" --name="Contributor" -v -e="$(openssl rand -hex 32)"
snarkjs zkey export verificationkey "$ZKEY1" "${DIR}/${CIRCUIT}_verification_key.json"

echo "Done. Use ${ZKEY1} for proving."
echo "Verify: snarkjs groth16 verify ${DIR}/${CIRCUIT}_verification_key.json prover/public.json prover/proof.json"
