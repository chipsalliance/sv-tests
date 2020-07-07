/*
:name: simple_concat_op_sim
:description: minimal concatenation operator simulation test (without result verification)
:type: simulation parsing
:tags: 11.4.12
*/
module top(input [1:0] a, input [1:0] b, output [3:0] c);

assign c = {a, b};

endmodule
