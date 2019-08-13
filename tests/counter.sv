/*
:name: counter
:description: A simple counter module
:expected_rc: 0
:tags: 5.2 5.3 5.4
*/
module counter_tb (
	clk,
	out
);
	input clk;
	output out;

	wire clk;
	reg out;

	reg [31:0] sum = 0;

	always @(posedge clk) begin
		if(sum >= 21) begin
			out <= 1;
			sum <= 0;
		end else begin
			out <= 0;
			sum <= sum + 1;
		end
	end
endmodule
