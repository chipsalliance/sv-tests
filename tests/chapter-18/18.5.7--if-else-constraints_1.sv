/*
:name: if_else_constraints_1
:description: if-else constraints test
:tags: 18.5.7
*/

class a;
    rand int b1, b2;
    constraint c1 { b1 == 5; }
    constraint c2 { if (b1 == 0) b2 == 10;
                    else b2 == 15;}
endclass
