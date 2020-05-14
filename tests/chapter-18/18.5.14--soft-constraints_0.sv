/*
:name: soft_constraints_0
:description: soft constraints test
:tags: 18.5.14
*/


class a;
    rand int b;

    constraint c {
        soft b > 4;
        soft b < 12; }
endclass
