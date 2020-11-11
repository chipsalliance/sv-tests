/*
:name: distribution_2
:description: distribution test
:should_fail_because: distribution shall not be applied to randc variables
:tags: 18.5.4
:type: simulation
*/

class a;
    randc int b;
    constraint c { b dist {3 := 0, 10 := 5}; }
endclass
