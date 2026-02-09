#!/usr/bin/env bash
# Compile hash_preimage circuit (run from zk2/)
set -e
circom hash_preimage.circom --r1cs --wasm --sym -o . -l node_modules
echo "Built: hash_preimage.r1cs hash_preimage.sym hash_preimage_js/"
