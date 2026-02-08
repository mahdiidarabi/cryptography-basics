# zkBasics - Zero Knowledge Proofs with Circom

A simple introduction to zero-knowledge proofs using [Circom](https://github.com/iden3/circom), demonstrating the complete workflow from circuit design to proof generation and verification.

## Overview

This project implements a basic zero-knowledge proof system using a simple multiplier circuit. The circuit proves knowledge of two private inputs `a` and `b` such that their product `c = a * b` equals a public value, without revealing the actual values of `a` and `b`.

## Circuit Description

The circuit (`Multiplier2.circom`) is a straightforward multiplier that takes two private inputs and outputs their product:

```circom
template Multiplier2() {
    signal input a;
    signal input b;
    signal output c;
    c <== a*b;
}

component main = Multiplier2();
```

- **Input signals**: `a`, `b` (private)
- **Output signal**: `c` (public, computed as `a * b`)

## Project Structure

```
zkBasics/
├── Multiplier2.circom          # Circom circuit source code
├── Multiplier2.r1cs             # Compiled R1CS constraint system
├── Multiplier2.sym              # Symbol file for debugging
├── Multiplier2_js/              # JavaScript witness generator
│   ├── generate_witness.js     # Witness generation script
│   ├── input.json              # Example input (a=3, b=11)
│   ├── Multiplier2.wasm        # Compiled WebAssembly
│   └── witness.wtns            # Generated witness file
├── Multiplier2_cpp/             # C++ witness generator
│   ├── main.cpp                # C++ witness generation program
│   ├── Makefile                # Build configuration
│   └── ...                     # C++ circuit implementation files
├── snarkjs/                     # Trusted setup artifacts
│   ├── pot12_final.ptau        # Powers of Tau final file
│   ├── multiplier2_0000.zkey   # Proving key (phase 1)
│   ├── multiplier2_0001.zkey   # Proving key (phase 2)
│   └── verification_key.json   # Verification key
├── prover/                      # Proof generation artifacts
│   ├── proof.json              # Generated proof
│   └── public.json             # Public inputs/outputs
└── verifier/                    # Verification artifacts
    ├── proof.json               # Proof to verify
    ├── public.json              # Public inputs/outputs
    └── verification_key.json    # Verification key
```

## Prerequisites

- [Circom](https://docs.circom.io/getting-started/installation/) - Circuit compiler
- [snarkjs](https://github.com/iden3/snarkjs) - ZK-SNARK implementation
- Node.js (for JavaScript witness generation)
- C++ compiler (for C++ witness generation, optional)

## Workflow

### 1. Compile the Circuit

Compile the Circom circuit to generate the R1CS constraint system and WebAssembly:

```bash
circom Multiplier2.circom --r1cs --wasm --sym
```

This generates:
- `Multiplier2.r1cs` - Rank-1 Constraint System
- `Multiplier2.wasm` - WebAssembly for witness generation
- `Multiplier2.sym` - Symbol file for debugging

### 2. Generate Witness

Create a witness file that proves you know valid inputs for the circuit.

#### Using JavaScript:

```bash
cd Multiplier2_js
node generate_witness.js Multiplier2.wasm input.json witness.wtns
```

#### Using C++:

```bash
cd Multiplier2_cpp
make
./main ../Multiplier2_js/input.json witness.wtns
```

The `input.json` file should contain your private inputs:
```json
{
  "a": "3",
  "b": "11"
}
```

### 3. Trusted Setup (Powers of Tau)

Generate the trusted setup parameters (if not already done):

```bash
# Phase 1: Powers of Tau
snarkjs powersoftau new bn128 12 pot12_0000.ptau -v
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v
snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v

# Phase 2: Circuit-specific setup
snarkjs groth16 setup Multiplier2.r1cs pot12_final.ptau multiplier2_0000.zkey
snarkjs zkey contribute multiplier2_0000.zkey multiplier2_0001.zkey --name="1st Contributor Name" -v
snarkjs zkey export verification_key multiplier2_0001.zkey verification_key.json
```

### 4. Generate Proof

Generate a zero-knowledge proof:

```bash
snarkjs groth16 prove multiplier2_0001.zkey witness.wtns proof.json public.json
```

This creates:
- `proof.json` - The zero-knowledge proof
- `public.json` - Public inputs/outputs (in this case, the output `c`)

### 5. Verify Proof

Verify the proof:

```bash
snarkjs groth16 verify verification_key.json public.json proof.json
```

If the proof is valid, you'll see: `OK` or `[INFO] snarkJS: OK!`

## Example

With inputs `a = 3` and `b = 11`:
- The circuit computes `c = 3 * 11 = 33`
- The public output `33` is revealed
- The proof demonstrates knowledge of `a` and `b` without revealing their values
- Anyone can verify the proof using only the public output and verification key

## Understanding Zero-Knowledge Proofs

This project demonstrates the core concept of zero-knowledge proofs:

1. **Privacy**: The prover can prove they know values `a` and `b` without revealing them
2. **Correctness**: The verifier can confirm that `c = a * b` without knowing `a` or `b`
3. **Trust**: The proof is cryptographically secure and cannot be forged

## Additional Notes

- The `rsa/` folder contains separate RSA encryption examples (not directly related to the ZK circuit)
- The witness generation can be done in either JavaScript or C++ - both produce equivalent results
- The trusted setup (powers of tau) is a one-time ceremony that must be performed securely
- For production use, consider using a multi-party trusted setup ceremony

## Resources

- [Circom Documentation](https://docs.circom.io/)
- [snarkjs Documentation](https://github.com/iden3/snarkjs)
- [Zero-Knowledge Proofs Explained](https://z.cash/technology/zksnarks/)

