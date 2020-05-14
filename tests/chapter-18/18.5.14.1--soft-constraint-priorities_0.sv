/*
:name: soft_constraint_priorities_0
:description: soft constraint priorities test
:tags: 18.5.14.1
*/


class a1;
    rand int b;

    constraint c1 {
        soft b > 4;
        soft b < 12; }
endclass

class a2 extends a1;
    constraint c2 { soft b == 20; }
endclass
