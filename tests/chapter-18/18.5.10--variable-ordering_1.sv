/*
:name: variable_ordering_1
:description: variable ordering test
:should_fail_because: randc vars are not allowed, they are always solved before any other
:tags: 18.5.10
:type: simulation
*/

class a;
    rand bit b1;
    randc int b2;

    constraint c1 { b1 -> b2 == 0; }
    constraint c2 { solve b1 before b2; }
endclass

