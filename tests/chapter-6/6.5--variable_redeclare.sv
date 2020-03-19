/*
:name: variable_redeclare
:description: Variable redeclaration tests
:should_fail_because: Variable redeclaration tests
:tags: 6.5
:type: simulation
*/
module top();
	reg v;
	wire v;
endmodule
