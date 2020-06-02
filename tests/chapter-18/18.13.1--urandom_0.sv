/*
:name: urandom_0
:description: urandom() test
:tags: 18.13.1
*/

class a;
    function int unsigned do_urandom();
        int unsigned x;
        x = $urandom();
        return x;
    endfunction
endclass
