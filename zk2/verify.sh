#!/usr/bin/env bash
# Verify the zcash_pour proof. Run from zk2/
set -e

snarkjs groth16 verify snarkjs/zcash_pour_verification_key.json prover/public.json prover/proof.json
