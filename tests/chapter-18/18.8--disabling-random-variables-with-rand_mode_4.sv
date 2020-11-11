/*
:name: disabling-random-variables-with-rand_mode_4
:description: rand_mode() test
:should_fail_because: The rand_mode() method is built-in and cannot be overridden.
:tags: 18.8
:type: simulation
*/

class a1;
    rand int x;
    function int rand_mode();
        return 1;
    endfunction
endclass
