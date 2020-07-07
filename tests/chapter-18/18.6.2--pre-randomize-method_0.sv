/*
:name: pre_randomize_method_0
:description: pre_randomize() method test
:tags: 18.6.2
*/

class a;
    rand int b;
    int d;

    constraint c { b == 5; }
    function void pre_randomize();
        d = 20;
    endfunction
endclass
