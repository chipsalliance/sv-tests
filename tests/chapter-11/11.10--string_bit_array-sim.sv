/*
:name: string_bit_array_sim
:description: string stored in bit array simulation test
:type: simulation parsing
:tags: 11.10
*/
module top();

bit [8*14:1] a;

initial begin
	a = "Test";
    $display(":assert: ('Test' == %s)", a);
end

endmodule
