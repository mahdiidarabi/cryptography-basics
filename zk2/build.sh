#!/usr/bin/env bash
# Compile the zcash_pour circuit. Run from zk2/
#
# Equivalent to Circom doc:
#   circom zcash_pour.circom --r1cs --wasm --sym --c
set -e

CIRCUIT=zcash_pour

# Create current dir for outputs (circom writes here with -o .)
# Compile: produces .r1cs, .sym, zcash_pour_js/ (WASM + JS witness), zcash_pour_cpp/ (C++ witness)
circom "$CIRCUIT.circom" --r1cs --wasm --sym --c -o . -l node_modules

echo "Build done. Created: $CIRCUIT.r1cs, $CIRCUIT.sym, ${CIRCUIT}_js/, ${CIRCUIT}_cpp/"
