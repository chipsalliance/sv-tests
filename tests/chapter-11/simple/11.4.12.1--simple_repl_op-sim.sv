/*
:name: simple_repl_op_sim
:description: minimal replication operator simulation test (without result verification)
:type: simulation parsing
:tags: 11.4.12.1
*/
module top(input [1:0] a, output [15:0] b);

assign b = {8{a}};

endmodule
