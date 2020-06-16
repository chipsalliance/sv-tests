/*
:name: string_concat
:description: string concatenation test
:type: simulation parsing
:tags: 11.10.1
*/
module top();

bit [8*14:1] a;
bit [8*14:1] b;

initial begin
	a = "Test";
	b = "TEST";
	$display(":assert: ('TEST' in '%s')", {a, b});
	$display(":assert: ('Test' in '%s')", {a, b});
end

endmodule
