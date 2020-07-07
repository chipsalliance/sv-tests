/*
:name: pure_constraint_0
:description: pure constraint test
:tags: 18.5.2
*/

virtual class a;
    pure constraint c;
endclass

class a2 extends a;
    rand int b2;
    constraint c { b2 == 5; }
endclass
