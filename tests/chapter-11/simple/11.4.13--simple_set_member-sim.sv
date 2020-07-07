/*
:name: simple_set_member_sim
:description: minimal inside operator simulation test (without result verification)
:type: simulation parsing
:tags: 11.4.13
*/
module top(input [3:0] a, output b);

assign b = (a inside {2, 3, 4, 5});

endmodule
