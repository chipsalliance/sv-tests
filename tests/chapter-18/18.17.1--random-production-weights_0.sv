/*
:name: random_production_weights_0
:description: randsequence weights test
:tags: 18.17.1
*/

function int F();
    int x;
    randsequence( main )
        main : first := 1 | second := 0;
        first : { x = -2; };
        second : { x = 2; };
    endsequence
    return x;
endfunction
