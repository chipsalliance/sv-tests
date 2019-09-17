/*
:name: operations-on-arrays-rw
:description: Test packed arrays operations support (R & W)
:should_fail: 0
:tags: 7.4.3
*/
module top ();

bit [7:0] arr;

initial begin
	arr = 8'h00;
	$display(":assert: ('%h' == '00')", arr);

	arr = 8'hde;
	$display(":assert: ('%h' == 'de')", arr);

	arr = 8'had;
	$display(":assert: ('%h' == 'ad')", arr);
end

endmodule
