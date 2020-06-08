/*
:name: array_reduction_iterative_constraints_0
:description: array reduction iterative constraints test
:tags: 18.5.8.2
*/

class a;
    rand int B[5];
    constraint c { A.sum() == 5; }
endclass
