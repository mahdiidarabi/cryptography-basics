pragma circom 2.1.0;

include "node_modules/circomlib/circuits/poseidon.circom";
include "node_modules/circomlib/circuits/comparators.circom";

template HashListCheckInternal(n) {
    // Private inputs (NOT main)
    signal input r;
    signal input j;

    // Public list (will be wired from main)
    signal input hashes[n];

    signal output ok;

    // Hash(r)
    component h = Poseidon(1);
    h.inputs[0] <== r;
    signal hr;
    hr <== h.out;

    // Selectors
    signal sel[n];
    component eq[n];

    for (var i = 0; i < n; i++) {
        eq[i] = IsEqual();
        eq[i].in[0] <== j;
        eq[i].in[1] <== i;
        sel[i] <== eq[i].out;
    }

    // Sum selectors
    signal sumSel[n+1];
    sumSel[0] <== 0;
    for (var i = 0; i < n; i++) {
        sumSel[i+1] <== sumSel[i] + sel[i];
    }
    sumSel[n] === 1;

    // Select hash
    signal selectedHash[n+1];
    selectedHash[0] <== 0;
    for (var i = 0; i < n; i++) {
        selectedHash[i+1] <== selectedHash[i] + sel[i] * hashes[i];
    }

    hr === selectedHash[n];

    ok <== 1;
}

template Main(n) {
    // PUBLIC inputs
    signal input hashes[n];

    // PRIVATE inputs (witness only)
    signal input r;
    signal input j;

    // PUBLIC output
    signal output ok;

    component c = HashListCheckInternal(n);

    // Wire public
    for (var i = 0; i < n; i++) {
        c.hashes[i] <== hashes[i];
    }

    // Wire private
    c.r <== r;
    c.j <== j;

    ok <== c.ok;
}

component main = Main(10);
