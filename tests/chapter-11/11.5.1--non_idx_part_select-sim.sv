/*
:name: non_idx_part_select_sim
:description: non-indexed part-select bit simulation test
:type: simulation parsing
:tags: 11.5.1
*/
module top();
logic [15:0] a = 16'h1234;
logic [3:0] b;

initial begin
	b = a[11:8];
    $display(":assert: (2 == %d)", b);
end

endmodule
