/*
:name: operations-on-arrays-treat-as-integer
:description: Test packed arrays operations support (treat array as integer)
:should_fail: 0
:tags: 7.4.3
*/
module top ();

bit [7:0] arr_a;
bit [7:0] arr_b;

initial begin
	arr_a = 8'd17;
	arr_b = (arr_a + 29);
	$display(":assert: (%d == 46)", arr_b);
end

// TODO: not sure if that should fail or not
// TODO: veriator fails with:
// TODO: "Operator ADD expects 32 bits on the LHS, but LHS's VARREF 'a' generates 8 bits."
//
// :begin: treat-as-integer
//bit [7:0] a;
//int b;
//
//assign a = 8'd1;
//assign b = (a + 4);
// :end:

// :begin: treat-as-integer-same-size
//bit [31:0] a;
//int b;
//
//assign a = 32'd1;
//assign b = (a + 4);
// :end:

endmodule
