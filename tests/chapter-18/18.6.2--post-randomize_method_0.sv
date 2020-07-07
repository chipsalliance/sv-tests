/*
:name: post_randomize_method_0
:description: post_randomize() method test
:tags: 18.6.2
*/

class a;
    rand int b;
    int d;

    constraint c { b == 5; }
    function void post_randomize();
        d = 20;
    endfunction
endclass
