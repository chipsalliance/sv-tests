/*
:name: case_production_statements_0
:description: randcase case statement test
:tags: 18.17.3
*/

function int F();
    int x;
    randsequence( main )
      main : case (switch)
          0 : zero;
          1 : first;
          2 : second;
          default : third;
      endcase;
      zero2 : { x = 0; };
      first : { x = 10; };
      second : { x = 2; };
      third : { x = 3; };
    endsequence

    return x;
endfunction
