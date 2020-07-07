/*
:name: in-line_constraints--randomize_5
:description: in-line constraints test - randomize()
:tags: 18.7
*/

class a;
    rand int x;
    int y = -1;
endclass

function int F(a obj, int y);
    F = obj.randomize() with (x) { x > 0; x < y; };
endfunction
