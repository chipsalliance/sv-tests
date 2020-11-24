/*
:name: class_member_test_19
:description: Test
:tags: 8.3
*/
localparam N = 10;

class myclass;
extern function void subr(bit x[N]);
endclass

function void myclass::subr(bit x[N]);
endfunction

