/*
:name: uniqueness_constraints_0
:description: uniqueness constraints test
:tags: 18.5.5
*/

class a;
    rand int b1, b2;
    constraint c1 { b1, b2 inside {3, 10}; }
    constraint c2 { unique {b1, b2}; }
endclass
