/*
:name: urandom_2
:description: urandom() test
:tags: 18.13.1
*/

class a;
    function int unsigned do_urandom(int seed);
        int unsigned x;
        x = $urandom(seed);
        return x;
    endfunction
endclass
