/*
:name: pure_constraint_2
:description: pure constraint test
:should_fail_because: pure constraint must be implemented by non-virtual class
:tags: 18.5.2
:type: simulation
*/

virtual class a;
    pure constraint c;
endclass

class a2 extends a;
endclass
