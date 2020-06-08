/*
:name: local_scope_resolution_0
:description: local:: scope resolution test
:tags: 18.7.1
*/

class a;
    rand int x;
endclass

function int F(a obj, int x);
    F = obj.randomize() with {x < local::x; };
endfunction
