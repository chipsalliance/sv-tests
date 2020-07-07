/*
:name: simple_unpack_stream_sim
:description: minimal stream unpack simulation test (without result verification)
:type: simulation parsing
:tags: 11.4.14.3
*/
module top(input [1:0] a, input [1:0] b, input [1:0] c, output [5:0] d);

    assign d = {<<2 {a, b, c}};

endmodule
