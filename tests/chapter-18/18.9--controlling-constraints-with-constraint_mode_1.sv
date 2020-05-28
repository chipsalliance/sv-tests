/*
:name: controlling_constraints_with_constraint_mode_1
:description: constraint_mode() test
:should_fail_because: The constraint_mode() method is built-in and cannot be overridden.
:tags: 18.8
*/

class a;
    rand int x;
    function int constraint_mode();
        return 1;
    endfunction
endclass
