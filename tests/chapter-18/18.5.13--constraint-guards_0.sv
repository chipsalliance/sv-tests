/*
:name: constraint_guards_0
:description: constraint guards test
:tags: 18.5.13
*/

class b;
    int d1;
endclass

class a;
    rand int b1;
    b next;

    constraint c1 { if (next == null) b1 == 5; }
endclass
