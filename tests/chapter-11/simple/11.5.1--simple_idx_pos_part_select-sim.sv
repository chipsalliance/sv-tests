/*
:name: simple_idx_pos_part_select_sim
:description: minimal indexed positive part-select bit simulation test (without result verification)
:type: simulation parsing
:tags: 11.5.1
*/
module top(input [15:0] a, output [3:0] b);

    assign b = a[0+:4];

endmodule
