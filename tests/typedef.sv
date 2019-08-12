/*
:name: typedef
:description: A module testing typedef support
:expected: 0
:verifies: 6.18
*/
module typedef_tb (
	clk,
	in,
	out
);
	input clk;
	input in;
	output out;

	typedef wire wire_t;

	wire_t a;

	assign a = in;
	assign out = a;

endmodule
