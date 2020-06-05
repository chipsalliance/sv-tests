/*
:name: repeat_production_statements_0
:description: repeat statement test
:tags: 18.17.4
*/

function int F();
    int x;
    randsequence( main )
      main : first;
      first : repeat(10) second;
      second : { x = x + 1; };
    endsequence
    return x;
endfunction
