/*
:name: constraint_inheritance_0
:description: contraint inheritance test
:tags: 18.5.2
*/

class a;
    rand int b;
    constraint c { b == 5; };
endclass

class a2 extends a;
    rand int b2;
    constraint c2 { b2 == b; }
endclass
