/*
:name: class_member_test_19
:description: Test
:tags: 8.3
*/
class myclass;
typedef logic bool;
localparam int N = 2;
extern function void subr(bool x[N]);
endclass

function void myclass::subr(bool x[N]); endfunction
