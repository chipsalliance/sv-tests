/*
:name: unsigned_func_sim
:description: $unsigned() simulation test
:type: simulation parsing
:tags: 11.7
*/
module top();

logic [7:0] a;

initial begin
	a = $unsigned(-4);
    $display(":assert: (0b11111100 == %d)", a);
end

endmodule
