/*
:name: operations-on-arrays-variable-slice-rw
:description: Test packed arrays operations support (Variable slice)
:should_fail: 0
:tags: 7.4.3
*/
module top ();

bit [7:0] arr_a;
bit [7:0] arr_b;

parameter integer c = 3;

initial begin
	arr_a = 8'hff;
	arr_b = 8'h00;
	$display(":assert: (('%h' == 'ff') and ('%h' == '00'))", arr_a, arr_b);

	arr_b[4+:c] = arr_a[1+:c];
	$display(":assert: ('%b' == '01110000')", arr_b);
end

endmodule
