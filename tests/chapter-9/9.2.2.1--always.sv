/*
:name: always
:description: always check
:tags: 9.2.2.1 9.4.1
*/
module always_tb ();
	wire a = 0;
	always #5 a = ~a;
endmodule
