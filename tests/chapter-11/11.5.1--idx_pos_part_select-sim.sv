/*
:name: idx_pos_part_select_sim
:description: indexed positive part-select bit simulation test
:type: simulation parsing
:tags: 11.5.1
*/
module top();
logic [15:0] a = 16'h1234;
logic [7:0] b;

initial begin
	b = a[0+:8];
    $display(":assert: (0x34 == 0x%x)", b);
end

endmodule
