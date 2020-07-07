/*
:name: isunknown_function
:description: $isunknown test
:tags: 20.9
:type: simulation parsing
*/

module top();

initial begin
	parameter [3:0] val0 = 4'b000x;
	parameter [3:0] val1 = 4'b000z;
	parameter [3:0] val2 = 4'b00xz;
	parameter [3:0] val3 = 4'b0000;
	$display(":assert: (%d == 1)", $isunknown(val0));
	$display(":assert: (%d == 1)", $isunknown(val1));
	$display(":assert: (%d == 1)", $isunknown(val2));
	$display(":assert: (%d == 0)", $isunknown(val3));
end

endmodule
