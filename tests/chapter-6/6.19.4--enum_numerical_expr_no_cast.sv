/*
:name: enum_numerical_expr_no_cast
:description: enum numerical expression without casting
:should_fail_because: enum numerical expression without casting
:tags: 6.19.4
:type: simulation
*/
module top();
	typedef enum {a, b, c, d} e;

	initial begin
		e val;
		val = a;
		val += 1;
	end
endmodule
