/*
:name: value_passing_between_productions_0
:description: value passing in randsequence test
:tags: 18.17.7
*/

function int F();
    int x;
    randsequence( main )
      main : first second third;
      first : add(10);
      second : add(5);
      third : add();
      add (int y = 2) : { x = x + y; };
    endsequence
    return x;
endfunction
