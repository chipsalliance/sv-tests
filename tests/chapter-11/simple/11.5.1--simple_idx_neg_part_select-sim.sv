/*
:name: simple_idx_neg_part_select_sim
:description: minimal indexed negative part-select bit simulation test (without result verification)
:type: simulation parsing
:tags: 11.5.1
*/
module top(input [15:0] a, output [3:0] b);

    assign b = a[15-:4];

endmodule
