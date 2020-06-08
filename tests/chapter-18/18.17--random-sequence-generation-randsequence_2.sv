/*
:name: random_sequence_generation_randsequence_2
:description: randsequence test
:tags: 18.17
*/

function int F();
    int x;
    randsequence( main )
        main : first | second;
        first : { x = -2; };
        second : { x = 2; };
    endsequence
    return x;
endfunction
