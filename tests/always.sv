/*
:name: always
:description: A module testing various structured procedures
:expected: 0
:verifies: 9.2
*/
module always_tb (
	clk,
	in,
	en,
	out
);
	input clk;
	input in;
	input en;
	output out;

	reg test_ff = 0;
	reg test_latch = 0;
	wire test_comb = 0;

	initial begin
		$display("Initial message");
	end

	always begin
		out = test_ff & test_latch & test_comb;
	end

	always_comb
	begin
		test_comb = in & en;
	end

	always_latch
	begin
		if(en)
			test_latch <= in;
	end

	always_ff @(posedge clk)
	begin
		test_ff <= in;
	end

	final
	begin
		$display("Final message");
	end

endmodule
