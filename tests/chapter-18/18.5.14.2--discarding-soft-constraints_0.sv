/*
:name: discarding_soft_constraints_0
:description: discarding soft constraints test
:tags: 18.5.14.2
*/


class a;
    rand int b;

    constraint c1 {
        soft b > 4;
        soft b < 12; }

    constraint c2 { disable soft b; }
    constraint c3 { soft b == 20; }
endclass
