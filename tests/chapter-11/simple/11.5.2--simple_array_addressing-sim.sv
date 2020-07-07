/*
:name: simple_array_addressing_sim
:description: minimal array addressing simulation test (without result verification)
:type: simulation parsing
:tags: 11.5.2
*/
module top(input [7:0] a, output [7:0] b);

reg [7:0] mem [0:255];

assign b = mem[a];

endmodule
