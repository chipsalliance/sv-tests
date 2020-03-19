/*
:name: real_idx
:description: real indexing tests
:should_fail_because: it is illegal to do bit select on real data type
:tags: 6.12
:type: simulation
*/
module top();
	real a = 0.5;
	wire b;

	assign b = a[2];
endmodule
