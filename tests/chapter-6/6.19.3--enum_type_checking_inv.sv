/*
:name: enum_type_checking_inv
:description: invalid enum assignment tests
:should_fail_because: enum enforces strict type checking rules
:tags: 6.19.3
:type: simulation
*/
module top();
	typedef enum {a, b, c, d} e;

	initial begin
		e val;
		val = 1;
	end
endmodule
