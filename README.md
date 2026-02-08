# Cryptography Basics

A collection of educational implementations covering fundamental cryptographic concepts, from finite field arithmetic to zero-knowledge proofs. This repository serves as a learning resource for understanding the mathematical foundations and practical applications of modern cryptography.

## Overview

This project provides hands-on implementations of core cryptographic primitives and protocols, organized into focused modules. Each module includes working code, examples, and detailed documentation to help understand both the theory and practice of cryptography.

## Project Structure

### 📁 [fieldBasics](./fieldBasics/)

Fundamental implementations for working with finite fields, prime numbers, cyclic groups, and cryptographic hash functions. These are essential building blocks for many cryptographic algorithms.

**Key Features:**
- Prime number operations and primality testing
- Modular arithmetic and fast exponentiation
- Generator (primitive root) finding
- Cyclic group analysis
- Cryptographic hash functions

📖 **[Read the fieldBasics README](./fieldBasics/README.md)** for detailed documentation and examples.

### 📁 [zkBasics](./zkBasics/)

A practical introduction to zero-knowledge proofs using [Circom](https://github.com/iden3/circom). Demonstrates the complete workflow from circuit design to proof generation and verification with a simple multiplier circuit.

**Key Features:**
- Circom circuit implementation
- Witness generation (JavaScript and C++)
- Trusted setup with snarkjs
- Proof generation and verification
- Complete ZK-SNARK workflow

📖 **[Read the zkBasics README](./zkBasics/README.md)** for step-by-step instructions.

## Getting Started

Each module is self-contained and can be explored independently:

1. **For finite field basics**: Start with [`fieldBasics/`](./fieldBasics/) to understand prime fields, generators, and cyclic groups
2. **For zero-knowledge proofs**: Start with [`zkBasics/`](./zkBasics/) to learn about ZK-SNARKs and circuit design

## Prerequisites

### fieldBasics
- Python 3.x
- Standard library only (no external dependencies)

### zkBasics
- [Circom](https://docs.circom.io/getting-started/installation/) - Circuit compiler
- [snarkjs](https://github.com/iden3/snarkjs) - ZK-SNARK implementation
- Node.js (for JavaScript witness generation)
- C++ compiler (optional, for C++ witness generation)

## Learning Path

### Beginner
1. Start with **fieldBasics** to understand:
   - Prime numbers and modular arithmetic
   - Finite fields and their properties
   - Generators and cyclic groups

### Intermediate
2. Move to **zkBasics** to learn:
   - Zero-knowledge proof concepts
   - Circuit design with Circom
   - Proof generation and verification

## Mathematical Foundations

This repository covers:

- **Finite Fields (Galois Fields)**: Prime fields GF(p) and their arithmetic
- **Group Theory**: Cyclic groups, generators, and subgroups
- **Number Theory**: Primality, factorization, and modular arithmetic
- **Zero-Knowledge Proofs**: ZK-SNARKs, R1CS, and trusted setup ceremonies

## License

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.

## Contributing

This is an educational project. Feel free to:
- Report issues
- Suggest improvements
- Submit pull requests
- Use the code for learning and teaching

## Resources

- [Circom Documentation](https://docs.circom.io/)
- [snarkjs Documentation](https://github.com/iden3/snarkjs)
- [Zero-Knowledge Proofs Explained](https://z.cash/technology/zksnarks/)
- [Finite Fields in Cryptography](https://en.wikipedia.org/wiki/Finite_field)

## Author

Mahdi Darabi

---

**Note**: This repository is intended for educational purposes. The implementations prioritize clarity and learning over production-grade performance or security. For production use, always use well-audited cryptographic libraries.
