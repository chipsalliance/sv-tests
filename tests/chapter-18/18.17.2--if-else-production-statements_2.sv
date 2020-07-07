/*
:name: if_else_production_statements_2
:description: randcase if-else test
:tags: 18.17.2
*/

function int F();
    int x;
    randsequence( main )
      main : first;
      first : if(switch) second else third;
      second : { x = 10; };
      third : { x = 5; };
    endsequence
    return x;
endfunction
