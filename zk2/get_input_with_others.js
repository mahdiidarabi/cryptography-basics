#!/usr/bin/env node
/**
 * Build input for hash_preimage circuit using:
 * - 9 hashes from a JSON file (e.g. other_hashs.json)
 * - 1 hash = Poseidon(secret)
 * Proves: "I know a secret whose hash is among these 10 hashes."
 *
 * Usage: node get_input_with_others.js <secret> [others.json]
 * Default others file: other_hashs.json
 */
const { buildPoseidon } = require("circomlibjs");
const { readFileSync } = require("fs");
const path = require("path");

async function main() {
  const secret = process.argv[2];
  if (!secret) {
    console.error("Usage: node get_input_with_others.js <secret> [others.json]");
    process.exit(1);
  }

  const othersPath = process.argv[3] || path.join(__dirname, "other_hashs.json");
  const raw = readFileSync(othersPath, "utf8");
  if (!raw || !raw.trim()) {
    throw new Error(`Empty or missing file: ${othersPath}`);
  }
  const others = JSON.parse(raw);
  if (!Array.isArray(others) || others.length !== 9) {
    throw new Error("others file must be a JSON array of exactly 9 hashes");
  }

  const poseidon = await buildPoseidon();
  const hashSecret = poseidon([BigInt(secret)]);
  const hashStr = poseidon.F.toString(hashSecret);

  // 10 hashes: 9 from file + secret's hash at index 9
  const hashes = [...others.map((h) => String(h)), hashStr];
  const j = 9;

  const input = { r: secret, j: String(j), hashes };
  console.log(JSON.stringify(input, null, 2));
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
