/*
:name: variable_multiple_assignments
:description: Variable multiple assignments tests
:should_fail_because: it shall be an error to have multiple continuous assignments
:tags: 6.5
:type: simulation
*/
module top();
	int v;

	assign v = 12;
	assign v = 13;
endmodule
