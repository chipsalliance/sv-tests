/*
:name: idx_select_sim
:description: indexed select bit simulation test
:type: simulation parsing
:tags: 11.5.1
*/
module top();
logic [15:0] a = 16'h1000;
logic b;
logic c;

initial begin
	b = a[12];
	c = a[5];
    $display(":assert: (1 == %d)", b);
    $display(":assert: (0 == %d)", c);
end

endmodule
