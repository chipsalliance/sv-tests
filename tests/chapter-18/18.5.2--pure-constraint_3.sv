/*
:name: pure_constraint_3
:description: pure constraint test
:tags: 18.5.2
*/

virtual class a;
    pure constraint c;
endclass

virtual class a2 extends a;
endclass
