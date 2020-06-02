/*
:name: urandom_range_0
:description: urandom_range() test
:tags: 18.13.2
*/

class a;
    function int do_urandom_range(int unsigned maxval, int unsigned minval);
        int unsigned val;
        val = $urandom_range(maxval, minval);
        return val;
    endfunction
endclass
