/*
:name: aborting_productions_break_and_return_0
:description: break statement test
:tags: 18.17.6
*/

function int F();
    int x;
    int break_on = 1;

    randsequence( main )
      main : first second third;
      first : { x = x + 10; };
      second : { if(break_on == 1) break; } fourth;
      third : { x = x + 10; };
      fourth : { x = x + 15; };
    endsequence
    return x;
endfunction
