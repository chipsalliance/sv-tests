/*
:name: random_weighted_case_randcase_2
:description: randcase test
:tags: 18.16
*/

function int F(int y);
    int a;
    randcase
        y - y : a = 5;
        y + y : a = 10;
    endcase
    return a;
endfunction
