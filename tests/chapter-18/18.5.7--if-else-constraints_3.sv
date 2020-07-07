/*
:name: if_else_constraints_3
:description: if-else constraints test
:tags: 18.5.7
*/

class a;
    rand int b1, b2, b3;
    constraint c1 { b1 == 5; }
    constraint c2 { b2 == 3; }
    constraint c3 { if (b1 == 0)
                      if (b2 == 2) b3 == 4; 
                      else b3 == 10;}
endclass
