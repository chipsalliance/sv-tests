/*
:name: implicit_external_constraint_0
:description: implicit external constraint test
:tags: 18.5.1
*/

class a;
    rand int b;
    constraint c;
endclass

constraint a::c { b == 0; }
