/*
:name: array_addressing_sim
:description: array addressing simulation test
:type: simulation parsing
:tags: 11.5.2
*/
module top();
logic [7:0] mem [0:1023];
logic [7:0] a;

initial begin
    mem[123] = 125;
	a = mem[123];
    $display(":assert: (125 == %d)", a);
end

endmodule
