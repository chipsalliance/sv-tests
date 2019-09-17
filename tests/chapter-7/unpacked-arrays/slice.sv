/*
:name: operations-on-arrays-slice-rw
:description: Test unpacked arrays operations support (R&W slice)
:should_fail: 0
:tags: 7.4.3
*/
module top ();

bit arr_a [7:0];
bit arr_b [7:0];

initial begin
	arr_a = '{1, 1, 1, 1, 1, 1, 1, 1};
	arr_b = '{0, 0, 0, 0, 0, 0, 0, 0};
	$display(":assert: ('%b%b%b%b_%b%b%b%b' == '1111_1111')",
		arr_a[7], arr_a[6], arr_a[5], arr_a[4], arr_a[3], arr_a[2], arr_a[1], arr_a[0]);
	$display(":assert: ('%b%b%b%b_%b%b%b%b' == '0000_0000')",
		arr_b[7], arr_b[6], arr_b[5], arr_b[4], arr_b[3], arr_b[2], arr_b[1], arr_b[0]);

	arr_b[5:3] = arr_a[2:0];
	$display(":assert: ('%b%b%b%b_%b%b%b%b' == '0011_1000')",
		arr_b[7], arr_b[6], arr_b[5], arr_b[4], arr_b[3], arr_b[2], arr_b[1], arr_b[0]);
end

endmodule
