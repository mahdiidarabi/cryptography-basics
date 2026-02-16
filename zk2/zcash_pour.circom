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
include "node_modules/circomlib/circuits/bitify.circom";

template SpendingCircuit(n) {
    // --- Private inputs (witness only; not exposed in main) ---
    signal input v;   // Verifier's random challenge
    signal input j;   // Index in [0..n-1]: position of that hash in the list
    signal input r_old;   // Secret preimage: we will check Poseidon(r) is in the list
    signal input sk_old;
    signal input rho;
    

    // --- Public list (wired from main; part of the public statement) ---
    signal input hashes[n];
    signal input sn_consume;

    // --- Output: 1 if Poseidon(r) == hashes[j], else constraint fails ---
    signal output ok;

    // --- Step 1: Compute Poseidon(r) ---
    // Same hash as circomlib/circomlibjs; use get_hash.js to compute hashes for input.json
    component h1 = Poseidon(1);
    h1.inputs[0] <== sk_old;
    signal pk_old;
    pk_old <== h1.out;


    component h2 = Poseidon(2);
    h2.inputs[0] <== rho;
    h2.inputs[1] <== pk_old;
    signal sn_produce;
    sn_produce <== h2.out;


    component h3 = Poseidon(2);
    h3.inputs[0] <== sn_produce;
    h3.inputs[1] <== sk_old;
    signal sn_consume_calculated;
    sn_consume_calculated <== h3.out;


    component h4 = Poseidon(3);
    h4.inputs[0] <== r_old;
    h4.inputs[1] <== sn_produce;
    h4.inputs[2] <== v;
    signal cm_j_calculated;
    cm_j_calculated <== h4.out;


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

    sn_consume === sn_consume_calculated;

    // --- Step 4: selectedHash = sum_i (sel[i] * hashes[i]) = hashes[j] ---
    // Linear combination: only the term with sel[j]=1 survives.
    signal selectedHash[n+1];
    selectedHash[0] <== 0;
    for (var i = 0; i < n; i++) {
        selectedHash[i+1] <== selectedHash[i] + sel[i] * hashes[i];
    }

    // --- Step 5: Poseidon(r) must equal the selected list element ---
    cm_j_calculated === selectedHash[n];

    ok <== 1;
}

template PourCircuit(n) {
    
    signal input v;

    signal input r1;
    signal input rho1;
    signal input v1;
    signal input pk1;

    signal input r2;
    signal input rho2;
    signal input v2;
    signal input pk2;

    v === v1 + v2;

    // Enforce v1 and v2 are non-negative (in [0, 2^64-1])
    component v1Bits = Num2Bits(64);
    v1Bits.in <== v1;

    component v2Bits = Num2Bits(64);
    v2Bits.in <== v2;


    component h1 = Poseidon(2);
    h1.inputs[0] <== rho1;
    h1.inputs[1] <== pk1;
    signal sn_produce_1;
    sn_produce_1 <== h1.out;


    component h2 = Poseidon(2);
    h2.inputs[0] <== rho2;
    h2.inputs[1] <== pk2;
    signal sn_produce_2;
    sn_produce_2 <== h2.out;


    component h11 = Poseidon(3);
    h11.inputs[0] <== r1;
    h11.inputs[1] <== sn_produce_1;
    h11.inputs[2] <== v1;
    signal output cm1;
    cm1 <== h11.out;

    component h21 = Poseidon(3);
    h21.inputs[0] <== r2;
    h21.inputs[1] <== sn_produce_2;
    h21.inputs[2] <== v2;
    signal output cm2;
    cm2 <== h21.out;

    signal output ok;
    ok <== 1;
}

template Main(n) {
    // PUBLIC inputs (part of the statement the verifier checks)
    signal input hashes[n];
    signal input sn_consume;

    // PRIVATE inputs (witness only; not revealed)
    signal input v;   // Verifier's random challenge
    signal input j;   // Index in [0..n-1]: position of that hash in the list
    signal input r_old;   // Secret preimage: we will check Poseidon(r) is in the list
    signal input sk_old;
    signal input rho;



    signal input r1;
    signal input rho1;
    signal input v1;
    signal input pk1;

    signal input r2;
    signal input rho2;
    signal input v2;
    signal input pk2;

    signal output cm1;
    signal output cm2;

    // PUBLIC output
    signal output ok;

    component c = SpendingCircuit(n);

    for (var i = 0; i < n; i++) {
        c.hashes[i] <== hashes[i];
    }
    c.sn_consume <== sn_consume;
    c.v <== v;
    c.j <== j;
    c.r_old <== r_old;
    c.sk_old <== sk_old;
    c.rho <== rho;

    component c2 = PourCircuit(n);
    c2.r1 <== r1;
    c2.rho1 <== rho1;
    c2.v1 <== v1;
    c2.pk1 <== pk1;
    c2.r2 <== r2;
    c2.rho2 <== rho2;
    c2.v2 <== v2;
    c2.pk2 <== pk2;
    c2.v <== v;

    cm1 <== c2.cm1;
    cm2 <== c2.cm2;

    ok <== c.ok * c2.ok;
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

component main {public [hashes, sn_consume]} = Main(10);
