/*
:name: manually_seeding_randomize_0
:description: manually seeding randomize test
:tags: 18.15
*/

class a;
    rand int x;
    function new (int seed);
        this.srandom(seed);
    endfunction
endclass
