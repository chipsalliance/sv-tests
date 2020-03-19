/*
:name: real_edge
:description: real edge event tests
:should_fail_because: it is illegal to use edge event controls on real type
:tags: 6.12
:type: simulation
*/
module top();
	real a = 0.5;
	always @(posedge a)
		$display("posedge");
endmodule
