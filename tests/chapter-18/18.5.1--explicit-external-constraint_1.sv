/*
:name: explicit_external_constraint_1
:description: explicit external constraint test
:should_fail_because: explicit contraint needs to be defined
:tags: 18.5.1
:type: simulation
*/

class a;
    rand int b;
    extern constraint c;
endclass
