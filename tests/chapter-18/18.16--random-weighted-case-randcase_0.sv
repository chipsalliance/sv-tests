/*
:name: random_weighted_case_randcase_0
:description: randcase test
:tags: 18.16
*/

function int F();
    int a;
    randcase
        0 : a = 5;
        1 : a = 10;
    endcase
    return a;
endfunction
