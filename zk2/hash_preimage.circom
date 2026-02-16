pragma circom 2.1.0;

// ---------------------------------------------------------------------------
// Hash list check circuit
// ---------------------------------------------------------------------------
// Proves: "I know a secret r and an index j such that Poseidon(r) equals
// the j-th element of a public list of n hashes" — without revealing r or j.
//
// Public:  hashes[n] (the list), ok (1 if the check passes).
// Private: r (preimage), j (index in 0..n-1).
// ---------------------------------------------------------------------------

include "node_modules/circomlib/circuits/poseidon.circom";
include "node_modules/circomlib/circuits/comparators.circom";

template HashListCheckInternal(n) {
    // --- Private inputs (witness only; not exposed in main) ---
    signal input r;   // Secret preimage: we will check Poseidon(r) is in the list
    signal input j;   // Index in [0..n-1]: position of that hash in the list

    // --- Public list (wired from main; part of the public statement) ---
    signal input hashes[n];

    // --- Output: 1 if Poseidon(r) == hashes[j], else constraint fails ---
    signal output ok;

    // --- Step 1: Compute Poseidon(r) ---
    // Same hash as circomlib/circomlibjs; use get_hash.js to compute hashes for input.json
    component h = Poseidon(1);
    h.inputs[0] <== r;
    signal hr;
    hr <== h.out;

    // --- Step 2: Build selectors so that sel[i] === 1 iff j === i ---
    // sel[i] = (j == i) ? 1 : 0  (using IsEqual from comparators)
    signal sel[n];
    component eq[n];
    for (var i = 0; i < n; i++) {
        eq[i] = IsEqual();
        eq[i].in[0] <== j;
        eq[i].in[1] <== i;
        sel[i] <== eq[i].out;
    }

    // --- Step 3: Enforce exactly one selector is 1 (j is in range and unique) ---
    // sumSel[n] = sum_i sel[i] === 1
    signal sumSel[n+1];
    sumSel[0] <== 0;
    for (var i = 0; i < n; i++) {
        sumSel[i+1] <== sumSel[i] + sel[i];
    }
    sumSel[n] === 1;

    // --- Step 4: selectedHash = sum_i (sel[i] * hashes[i]) = hashes[j] ---
    // Linear combination: only the term with sel[j]=1 survives.
    signal selectedHash[n+1];
    selectedHash[0] <== 0;
    for (var i = 0; i < n; i++) {
        selectedHash[i+1] <== selectedHash[i] + sel[i] * hashes[i];
    }

    // --- Step 5: Poseidon(r) must equal the selected list element ---
    hr === selectedHash[n];

    ok <== 1;
}

template Main(n) {
    // PUBLIC inputs (part of the statement the verifier checks)
    signal input hashes[n];

    // PRIVATE inputs (witness only; not revealed)
    signal input r;
    signal input j;

    // PUBLIC output
    signal output ok;

    component c = HashListCheckInternal(n);

    for (var i = 0; i < n; i++) {
        c.hashes[i] <== hashes[i];
    }
    c.r <== r;
    c.j <== j;

    ok <== c.ok;
}

// ---------------------------------------------------------------------------
// How to also expose the list of hashes as OUTPUTS
// ---------------------------------------------------------------------------
// Right now hashes are PUBLIC INPUTS: the prover supplies them and the
// verifier sees them. If you want the same list to appear as public OUTPUTS
// as well (e.g. so the verifier receives them in the same order as outputs):
//
// 1. Add an output array in Main(n):
//
//      signal output hashesOut[n];
//
// 2. Wire the inputs to the outputs (no new constraints):
//
//      for (var i = 0; i < n; i++) {
//          hashesOut[i] <== hashes[i];
//      }
//
// 3. Then public.json will contain: [ok, hashesOut[0], ..., hashesOut[n-1]]
//    (or the order your compiler uses for public signals). The verifier
//    can then read the list from the public output vector instead of (or
//    in addition to) the public input vector, depending on how your
//    verifier is implemented.
//
// Note: Having hashes as both inputs and outputs is redundant for the
// proof itself; use outputs only if your verification flow expects the
// list to be part of the public output.
// ---------------------------------------------------------------------------

component main {public [hashes]} = Main(10);
