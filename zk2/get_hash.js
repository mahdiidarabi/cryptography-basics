#!/usr/bin/env node
/**
 * Compute Poseidon(secret) - the public hash for a given secret.
 * Use the same secret in input.json when proving.
 * Usage: node get_hash.js [secret]
 *        node get_hash.js random   # use a random secret (Poseidon field element)
 * Default secret: 12345
 */
const { buildPoseidon } = require("circomlibjs");

async function main() {
  let secret = process.argv[2] || "12345";
  if (secret === "random") {
    const poseidon = await buildPoseidon();
    secret = poseidon.F.toString(poseidon.F.random());
  }
  const poseidon = await buildPoseidon();
  const hash = poseidon([BigInt(secret)]);
  const knownHash = poseidon.F.toString(hash);
  console.log(JSON.stringify({ secret, knownHash }, null, 2));
}

main().catch(console.error);
