#!/usr/bin/env node
/**
 * Generate input.json for hash_preimage circuit.
 * Creates a list of 10 hashes with hashes[j] = Poseidon(r), others = 0.
 * Usage: node get_input.js [r] [j]
 * Default: r=12345, j=0
 */
const { buildPoseidon } = require("circomlibjs");

async function main() {
  const r = process.argv[2] || "12345";
  const j = parseInt(process.argv[3] || "0", 10);
  if (j < 0 || j > 9) {
    throw new Error("j must be 0–9");
  }

  const poseidon = await buildPoseidon();
  const hashR = poseidon([BigInt(r)]);
  const hashStr = poseidon.F.toString(hashR);

  const hashes = Array(10).fill("0");
  hashes[j] = hashStr;

  const input = { r, j: String(j), hashes };
  console.log(JSON.stringify(input, null, 2));
}

main().catch(console.error);
