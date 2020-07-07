/*
:name: idx_neg_part_select_sim
:description: indexed negative part-select bit simulation test
:type: simulation parsing
:tags: 11.5.1
*/
module top();
logic [15:0] a = 16'h1234;
logic [7:0] b;

initial begin
	b = a[15-:8];
    $display(":assert: (0x12 == 0x%x)", b);
end

endmodule
