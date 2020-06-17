/*
:name: simple_idx_select_sim
:description: minimal indexed select bit simulation test (without result verification)
:type: simulation parsing
:tags: 11.5.1
*/
module top(input [3:0] a, output b);

    assign b = a[2];

endmodule
