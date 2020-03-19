/*
:name: variable_mixed_assignments
:description: Variable mixed assignments tests
:should_fail_because: mixing procedural and continuous assignments is illegal
:tags: 6.5
:type: simulation
*/
module top();
	wire clk = 0;
	int v;

	assign v = 12;
	always @(posedge clk) v <= ~v;
endmodule
