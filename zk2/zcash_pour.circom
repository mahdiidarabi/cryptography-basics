pragma circom 2.1.0;

// ---------------------------------------------------------------------------
// Zcash-style pour: spending_sn_circuit (note in list) + pour_circuit (split value)
// ---------------------------------------------------------------------------
//
// spending_sn_circuit: proves knowledge of (v, j, r_old, sk_old, rho) such that
//   sn_consume = hash(sn_produce || sk_old), sn_produce = hash(rho || hash(sk_old)),
//   and commitment = hash(r_old || sn_produce || v) equals cm_list[j].
// Public:  cm_list[n], sn_consume.  Private: v, j, r_old, sk_old, rho.
//
// pour_circuit: proves v = v1 + v2 and outputs cm1, cm2 for two new notes.
// ---------------------------------------------------------------------------

include "node_modules/circomlib/circuits/poseidon.circom";
include "node_modules/circomlib/circuits/comparators.circom";
include "node_modules/circomlib/circuits/multiplexer.circom";
include "node_modules/circomlib/circuits/bitify.circom";

template spending_sn_circuit(n) {
    // --- Private inputs (witness only; not exposed in main) ---
    signal input v;       // Value (amount) of the spent note (the cm)
    signal input j;       // Index in [0..n-1]: position of our commitment in cm_list
    signal input r_old;   // Secret random seed for the commitment; cm = hash(r_old || sn_produce || v)
    signal input rho;     // Randomness for sn_produce; sn_produce = hash(rho || pk_old), pk_old = hash(sk_old)
    signal input sk_old;  // Secret key: defines ownership; sn_consume = hash(sn_produce || sk_old)

    // --- Public inputs (part of the statement the verifier checks) ---
    signal input cm_list[n];
    signal input sn_consume;

    // --- Output: 1 if the spending constraints hold (commitment == cm_list[j]), else constraint fails ---
    signal output ok;

    // --- Note hashes (match circomlib/circomlibjs; use get_hash.js for input.json) ---
    component h1 = Poseidon(1);
    h1.inputs[0] <== sk_old;
    signal pk_old;
    pk_old <== h1.out;

    // sn_produce = hash(rho || pk_old)
    component h2 = Poseidon(2);
    h2.inputs[0] <== rho;
    h2.inputs[1] <== pk_old;
    signal sn_produce;
    sn_produce <== h2.out;

    // Enforce sn_consume = hash(sn_produce || sk_old)
    component h3 = Poseidon(2);
    h3.inputs[0] <== sn_produce;
    h3.inputs[1] <== sk_old;
    signal sn_consume_calculated;
    sn_consume_calculated <== h3.out;
    sn_consume_calculated === sn_consume;

    // Commitment for spent note: hash(r_old || sn_produce || v) must equal cm_list[j]
    component h4 = Poseidon(3);
    h4.inputs[0] <== r_old;
    h4.inputs[1] <== sn_produce;
    h4.inputs[2] <== v;
    signal cm_j_calculated;
    cm_j_calculated <== h4.out;

    // Linear combination: acc[n] = sum_i (isEq[i].out * cm_list[i]) = cm_list[j]
    signal acc[n+1];
    acc[0] <== 0;
    component isEq[n];
    for (var i = 0; i < n; i++) {
        isEq[i] = IsEqual();
        isEq[i].in[0] <== j;
        isEq[i].in[1] <== i;
        acc[i+1] <== acc[i] + isEq[i].out * cm_list[i];
    }
    signal cm_list_j_selected;
    cm_list_j_selected <== acc[n];
    cm_list_j_selected === cm_j_calculated;

    // Range check: j in [0..n-1] (LessThan(10) for n=10)
    component rangeJ = LessThan(10);
    rangeJ.in[0] <== j;
    rangeJ.in[1] <== n;
    rangeJ.out === 1;

    ok <== 1;
}

// Pour: split value v into two notes (v1, v2) with v = v1 + v2; output commitments cm1, cm2.
template pour_circuit() {
    signal input v;   // Total value (must equal v1 + v2)

    // Two new notes (all private)
    signal input r1;
    signal input rho1;
    signal input v1;
    signal input pk1;

    signal input r2;
    signal input rho2;
    signal input v2;
    signal input pk2;

    v === v1 + v2;

    // v1, v2 non-negative and fit in 32 bits (0 <= v1, v2 < 2^32)
    component range1 = Num2Bits(32);
    range1.in <== v1;
    component range2 = Num2Bits(32);
    range2.in <== v2;

    // Note 1: sn_produce_1 = hash(rho1 || pk1), cm1 = hash(r1 || sn_produce_1 || v1)
    component h1 = Poseidon(2);
    h1.inputs[0] <== rho1;
    h1.inputs[1] <== pk1;
    signal sn_produce_1;
    sn_produce_1 <== h1.out;

    component h11 = Poseidon(3);
    h11.inputs[0] <== r1;
    h11.inputs[1] <== sn_produce_1;
    h11.inputs[2] <== v1;
    signal output cm1 <== h11.out;

    // Note 2: sn_produce_2 = hash(rho2 || pk2), cm2 = hash(r2 || sn_produce_2 || v2)
    component h2 = Poseidon(2);
    h2.inputs[0] <== rho2;
    h2.inputs[1] <== pk2;
    signal sn_produce_2;
    sn_produce_2 <== h2.out;

    component h21 = Poseidon(3);
    h21.inputs[0] <== r2;
    h21.inputs[1] <== sn_produce_2;
    h21.inputs[2] <== v2;
    signal output cm2 <== h21.out;
}

template Main(n) {
    // Public inputs (verifier sees these)
    signal input cm_list[n];
    signal input sn_consume;

    // Private inputs — spending (witness only)
    signal input v;       // Value of the spent note (the cm)
    signal input j;       // Index in cm_list for our commitment
    signal input r_old;   // Secret random seed; cm = hash(r_old || sn_produce || v)
    signal input rho;     // Randomness for sn_produce; sn_produce = hash(rho || pk_old)
    signal input sk_old;  // Secret key; sn_consume = hash(sn_produce || sk_old)

    // Private inputs — pour (two new notes)
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
    signal output ok;

    component c = spending_sn_circuit(n);
    component p = pour_circuit();

    p.v <== v;
    p.r1 <== r1;
    p.rho1 <== rho1;
    p.v1 <== v1;
    p.pk1 <== pk1;
    p.r2 <== r2;
    p.rho2 <== rho2;
    p.v2 <== v2;
    p.pk2 <== pk2;

    cm1 <== p.cm1;
    cm2 <== p.cm2;

    c.v <== v;
    c.j <== j;
    c.r_old <== r_old;
    c.rho <== rho;
    c.sk_old <== sk_old;
    for (var i = 0; i < n; i++) {
        c.cm_list[i] <== cm_list[i];
    }
    c.sn_consume <== sn_consume;

    ok <== c.ok;
}

component main {public [cm_list, sn_consume]} = Main(10);
