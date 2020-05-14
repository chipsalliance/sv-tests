/*
:name: behavior_of_randomization_methods_4
:description: behavior of randomization methods test
:should_fail_because: The randomize() method is built-in and cannot be overridden.
:tags: 18.6.3
*/

class a;
    rand int b;
    constraint c { b > 5 && b < 12; }

    function void randomize();
        b = 7;
    endfunction
endclass
