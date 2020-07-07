/*
:name: in-line_constraints--randomize_3
:description: in-line constraints test - randomize()
:tags: 18.7
*/

class a;
    rand int x;
endclass

function int F(a obj, int y);
    F = obj.randomize() with (x) { x > 0; x < y; };
endfunction
