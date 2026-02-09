#!/usr/bin/env bash
# Trusted setup for hash_preimage (powers of tau + zkey). Run from zk2/
set -e

PTAU=pot12_final.ptau
CIRCUIT=hash_preimage

# Reuse multiplier's ptau if it exists; otherwise download Hermez pot12 final
mkdir -p snarkjs
if [ ! -f "snarkjs/${PTAU}" ]; then
  echo "Downloading powers of tau (pot12)..."
  curl -L -o snarkjs/${PTAU} "https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_12.ptau"
fi
PTAU=snarkjs/${PTAU}

echo "Phase 2: circuit-specific setup (zkey)..."
snarkjs groth16 setup ${CIRCUIT}.r1cs ${PTAU} snarkjs/${CIRCUIT}_0000.zkey
snarkjs zkey contribute snarkjs/${CIRCUIT}_0000.zkey snarkjs/${CIRCUIT}_0001.zkey --name="Contributor" -v -e="$(openssl rand -hex 32)"
snarkjs zkey export verificationkey snarkjs/${CIRCUIT}_0001.zkey snarkjs/${CIRCUIT}_verification_key.json

echo "Done. Use snarkjs/${CIRCUIT}_0001.zkey for proving."
