/*
:name: if_else_production_statements_0
:description: randcase if-else test
:tags: 18.17.2
*/

function int F();
    int x;
    randsequence( main )
      main : first;
      first : { if(switch ) x = 10; else x = 5; };
    endsequence
    return x;
endfunction
