/*
:name: in-line_constraints--randomize_1
:description: in-line constraints test - randomize()
:tags: 18.7
*/

class a1;
    rand int x;
endclass

class a2;
    int x, y;

    task do_randomize(a1 obj, int x, int z);
        int result;
        result = obj.randomize() with {x > 0; x < y + z;};
    endtask
endclass
