/*
:name: string_putc
:description: string.putc()  tests
:should_fail: 0
:tags: 6.16.2
*/
module top();
	string a = "Test";
	a.putc(2, "B");
endmodule
