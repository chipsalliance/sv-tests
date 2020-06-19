/*
:name: simple_cond_op_sim
:description: minimal ?: operator simulation test (without result verification)
:type: simulation parsing
:tags: 11.4.11
*/
module top(input a, output b);

assign b = (a) ? 0 : 1;

endmodule
