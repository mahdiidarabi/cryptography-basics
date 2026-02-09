#!/usr/bin/env bash
# Verify the hash preimage proof. Run from zk2/
set -e

snarkjs groth16 verify snarkjs/hash_preimage_verification_key.json prover/public.json prover/proof.json
