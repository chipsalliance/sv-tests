/*
:name: real_bit_select
:description: real bit select tests
:should_fail_because: it is illegal to do bit select on real data type
:tags: 6.12
:type: simulation
*/
module top();
	real a = 0.5;
	wire [3:0] b;
	wire c;

	assign c = b[a];
endmodule
