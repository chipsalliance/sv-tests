/*
:name: variable_ordering_0
:description: variable ordering test
:tags: 18.5.10
*/

class a;
    rand bit b1;
    rand int b2;

    constraint c1 { b1 -> b2 == 0; }
    constraint c2 { solve b1 before b2; }
endclass

