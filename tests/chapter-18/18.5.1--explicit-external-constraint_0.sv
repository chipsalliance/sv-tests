/*
:name: explicit_external_constraint_0
:description: explicit external constraint test
:tags: 18.5.1
*/

class a;
    rand int b;
    extern constraint c;
endclass

constraint a::c { b == 0; }
