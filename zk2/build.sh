#!/usr/bin/env bash
# Compile the zcash_pour circuit. Run this from the zk2/ directory.
set -e

CIRCUIT=zcash_pour

# Compile: produces .r1cs, .sym, and zcash_pour_js/ (with .wasm and witness generator)
circom "$CIRCUIT.circom" --r1cs --wasm --sym -o . -l node_modules

echo "Build done. Created: $CIRCUIT.r1cs, $CIRCUIT.sym, ${CIRCUIT}_js/"
