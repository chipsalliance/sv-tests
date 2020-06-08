/*
:name: soft_constraints_2
:description: soft constraints test
:should_fail_because: Soft constraints can only be specified on random variables; they may not be specified for randc variables.
:tags: 18.5.14
*/


class a;
    randc int b;

    constraint c {
        soft b > 4;
        soft b < 12; }
endclass
