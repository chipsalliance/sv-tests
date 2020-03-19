/*
:name: enum_xx_inv
:description: invalid enum with x tests
:should_fail_because: invalid enum with x tests
:tags: 6.19
:type: simulation
*/
module top();
	enum bit [1:0] {a=0, b=2'bxx, c=1} val;
endmodule
