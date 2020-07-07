/*
:name: concat_op_sim
:description: concatenation operator simulation test
:type: simulation parsing
:tags: 11.4.12
*/
module top();

bit [15:0] a;

bit [7:0] b = 8'h89;
bit [7:0] c = 8'h12;

initial begin
	a = {b, c};
    $display(":assert: (0x8912 == %d)", a);
end

endmodule
