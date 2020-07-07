/*
:name: randomization_of_scope_variables_0
:description: Randomization of scope variables - std::randomize() test
:tags: 18.12
*/

class a;
    function int do_randomize();
        int x, success;
        success = std::randomize(x);
        return success;
    endfunction
endclass
