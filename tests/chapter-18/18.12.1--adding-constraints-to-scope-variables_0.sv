/*
:name: adding_constraints_to_scope_variables_0
:description: Adding constraints to scope variables—std::randomize() with - test
:tags: 18.12.1
*/

class a;
    function int do_randomize(int y);
        int x, success;
        success = std::randomize(x) with {x > 0; x < y};
        return success;
    endfunction
endclass
