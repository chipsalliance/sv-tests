/*
:name: distribution_0
:description: distribution test
:tags: 18.5.4
*/

class a;
    rand int b;
    constraint c { b dist {3 := 1, 10 := 2}; }
endclass
