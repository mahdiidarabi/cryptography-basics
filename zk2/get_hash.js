#!/usr/bin/env node
/**
 * Helpers for zcash_pour circuit input.
 *
 * Hash definitions (match circuit):
 *   sn_produce = hash(rho || hash(sk_old))
 *   cm_list[j] = hash(r_old || sn_produce || v)
 *   sn_consume = hash(sn_produce || sk_old)
 *
 * Usage:
 *   node get_hash.js from-input [input.json]
 *     Read input.json, compute hash for cm_list[j]. Print value to paste at cm_list[j].
 *
 *   node get_hash.js complete-input [input.json] [--write]
 *     Read input.json, compute sn_consume and cm_list[j], print full JSON.
 *     With --write: overwrite the file (fixes "Only 15 out of 16" witness error).
 *
 *   node get_hash.js chain <sk_old> <rho> <r_old> <v> <j> [v1]
 *     Full input (spending + pour). v1+v2=v; default v1=2. Output includes r1, rho1, v1, pk1, r2, rho2, v2, pk2.
 *
 *   node get_hash.js single <x>
 *     Compute Poseidon(x). Use for ad-hoc hashing.
 *
 *   node get_hash.js random
 *     Print a random field element (for secrets).
 */
const { buildPoseidon } = require("circomlibjs");
const { readFileSync } = require("fs");
const path = require("path");

function toString(x) {
  return typeof x === "bigint" ? x.toString() : String(x);
}

async function main() {
  const mode = process.argv[2] || "chain";

  if (mode === "random") {
    const poseidon = await buildPoseidon();
    const r = poseidon.F.toString(poseidon.F.random());
    console.log(JSON.stringify({ random: r }, null, 2));
    return;
  }

  if (mode === "single") {
    const x = process.argv[3] || "12345";
    const poseidon = await buildPoseidon();
    const h = poseidon([BigInt(x)]);
    console.log(JSON.stringify({ input: x, hash: poseidon.F.toString(h) }, null, 2));
    return;
  }

  if (mode === "from-input") {
    const inputPath = path.resolve(process.argv[3] || "input.json");
    const raw = readFileSync(inputPath, "utf8");
    const data = JSON.parse(raw);
    const r_old = data.r_old;
    const sk_old = data.sk_old;
    const rho = data.rho;
    const v = data.v;
    const j = parseInt(data.j, 10);
    if (r_old == null || sk_old == null || rho == null || v == null || data.j == null) {
      console.error("input.json must contain: r_old, sk_old, rho, v, j");
      process.exit(1);
    }
    if (j < 0 || j > 9) {
      console.error("j must be 0..9");
      process.exit(1);
    }

    const poseidon = await buildPoseidon();
    const F = poseidon.F;
    // sn_produce = hash(rho || hash(sk_old))
    const pk_old = poseidon([BigInt(sk_old)]);
    const sn_produce = poseidon([BigInt(rho), pk_old]);
    // sn_consume = hash(sn_produce || sk_old)
    const sn_consume = poseidon([sn_produce, BigInt(sk_old)]);
    // cm_list[j] = hash(r_old || sn_produce || v)
    const hashAtJ = poseidon([BigInt(r_old), sn_produce, BigInt(v)]);

    console.error(`Paste into cm_list[${j}] in input.json:`);
    console.log(F.toString(hashAtJ));
    console.error(`Paste into sn_consume in input.json:\n${F.toString(sn_consume)}`);
    console.error(`sn_produce (for reference, not in input.json):\n${F.toString(sn_produce)}`);
    return;
  }

  if (mode === "complete-input") {
    const args = process.argv.slice(3).filter((a) => a !== "--write");
    const doWrite = process.argv.includes("--write");
    const inputPath = path.resolve(args[0] || "input.json");
    const raw = readFileSync(inputPath, "utf8");
    const data = JSON.parse(raw);
    const r_old = data.r_old;
    const sk_old = data.sk_old;
    const rho = data.rho;
    const v = data.v;
    const j = parseInt(data.j, 10);
    if (r_old == null || sk_old == null || rho == null || v == null || data.j == null) {
      console.error("input.json must contain: r_old, sk_old, rho, v, j");
      process.exit(1);
    }
    if (j < 0 || j > 9) {
      console.error("j must be 0..9");
      process.exit(1);
    }

    const vNum = parseInt(String(v), 10);
    const v1 = data.v1 != null ? String(data.v1) : "1";
    const v2 = data.v2 != null ? String(data.v2) : String(vNum - parseInt(v1, 10));

    const poseidon = await buildPoseidon();
    const F = poseidon.F;
    const pk_old = poseidon([BigInt(sk_old)]);
    const sn_produce = poseidon([BigInt(rho), pk_old]);
    const sn_consume = poseidon([sn_produce, BigInt(sk_old)]);
    const hashAtJ = poseidon([BigInt(r_old), sn_produce, BigInt(v)]);

    const cm_list = Array.isArray(data.cm_list) && data.cm_list.length === 10 ? [...data.cm_list] : Array(10).fill("0");
    cm_list[j] = F.toString(hashAtJ);

    const complete = {
      cm_list,
      sn_consume: F.toString(sn_consume),
      v,
      j: String(j),
      r_old,
      sk_old,
      rho,
      r1: data.r1 != null ? data.r1 : "1111",
      rho1: data.rho1 != null ? data.rho1 : "11111",
      v1,
      pk1: data.pk1 != null ? data.pk1 : "111111111",
      r2: data.r2 != null ? data.r2 : "2222",
      rho2: data.rho2 != null ? data.rho2 : "22222",
      v2,
      pk2: data.pk2 != null ? data.pk2 : "222222222",
    };
    const out = JSON.stringify(complete, null, 2);
    if (doWrite) {
      require("fs").writeFileSync(inputPath, out, "utf8");
      console.error(`Wrote ${inputPath} with sn_consume and cm_list[${j}] set.`);
    } else {
      console.log(out);
    }
    return;
  }

  if (mode === "chain") {
    const sk_old = process.argv[3] || "12345";
    const rho = process.argv[4] || "12345";
    const r_old = process.argv[5] || "13751379";
    const v = process.argv[6] || "5";
    const j = parseInt(process.argv[7] || "0", 10);
    const v1 = process.argv[8] || "2";  // v1 + v2 must equal v
    if (j < 0 || j > 9) {
      console.error("j must be 0..9");
      process.exit(1);
    }
    const vNum = parseInt(String(v), 10);
    const v1Num = parseInt(String(v1), 10);
    const v2Num = vNum - v1Num;
    if (v1Num < 0 || v2Num < 0) {
      console.error("v must be >= 2 and v1 in [1, v-1] so v2 = v - v1 is non-negative");
      process.exit(1);
    }
    const v2 = String(v2Num);

    const poseidon = await buildPoseidon();
    const F = poseidon.F;

    const pk_old = poseidon([BigInt(sk_old)]);
    const sn_produce = poseidon([BigInt(rho), pk_old]);
    const sn_consume = poseidon([sn_produce, BigInt(sk_old)]);
    const cm_j = poseidon([BigInt(r_old), sn_produce, BigInt(v)]);

    const cm_list = Array(10).fill("0");
    cm_list[j] = F.toString(cm_j);

    const input = {
      cm_list,
      sn_consume: F.toString(sn_consume),
      v,
      j: String(j),
      r_old,
      sk_old,
      rho,
      r1: "1111",
      rho1: "11111",
      v1,
      pk1: "111111111",
      r2: "2222",
      rho2: "22222",
      v2,
      pk2: "222222222",
    };
    console.log(JSON.stringify(input, null, 2));
    return;
  }

  console.error("Usage: node get_hash.js from-input [input.json]");
  console.error("       node get_hash.js complete-input [input.json] [--write]");
  console.error("       node get_hash.js chain <sk_old> <rho> <r_old> <v> <j> [v1]  # v1+v2=v, default v1=2");
  console.error("       node get_hash.js single <x>");
  console.error("       node get_hash.js random");
  process.exit(1);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
