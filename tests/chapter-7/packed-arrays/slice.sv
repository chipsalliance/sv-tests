/*
:name: operations-on-arrays-slice-rw
:description: Test packed arrays operations support (R&W slice)
:should_fail: 0
:tags: 7.4.3
*/
module top ();

bit [7:0] arr_a;
bit [7:0] arr_b;

initial begin
	arr_a = 8'hff;
	arr_b = 8'h00;
	$display(":assert: (('%h' == 'ff') and ('%h' == '00'))", arr_a, arr_b);

	arr_b[5:3] = arr_a[2:0];
	$display(":assert: ('%b' == '00111000')", arr_b);
end

endmodule
