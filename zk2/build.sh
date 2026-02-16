#!/usr/bin/env bash
# Compile zcash_pour circuit (run from zk2/)
set -e
circom zcash_pour.circom --r1cs --wasm --sym -o . -l node_modules
echo "Built: zcash_pour.r1cs zcash_pour.sym zcash_pour_js/"
