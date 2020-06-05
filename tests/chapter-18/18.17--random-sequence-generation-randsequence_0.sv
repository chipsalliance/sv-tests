/*
:name: random_sequence_generation_randsequence_0
:description: randsequence test
:tags: 18.17
*/

function int F();
    int x;
    randsequence( main )
        main : first second done;
        first : { x = x + 1; };
        second : { x = x + 2; };
        done : { x = x + 3; };
    endsequence
    return x;
endfunction
