/*
:name: interleaving_productions_rand_join_0
:description: rand join statement test
:tags: 18.17.5
*/

function int F();
    int x;
    randsequence( main )
      main : rand join first second;
      first : { x = x + 20; };
      second : { x = x - 10; };
    endsequence
    return x;
endfunction
