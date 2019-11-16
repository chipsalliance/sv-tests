/*
:name: cont_assignment_delay
:description: continuous assignment with delay test
:should_fail: 1
:tags: 10.3
*/
module top(input a, input b);

wire w;

// Illegal to procedurally assign to wire, IEEE Table 10-1
initial
	w = #10 a & b;

endmodule
