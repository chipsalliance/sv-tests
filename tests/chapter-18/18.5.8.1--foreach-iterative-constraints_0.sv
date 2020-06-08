/*
:name: foreach_iterative_constraints_0
:description: foreach iterative constraints test
:tags: 18.5.8.1
*/

class a;
    rand int B[5];
    constraint c { foreach ( B [ i ] ) B[i] == 5; }
endclass
