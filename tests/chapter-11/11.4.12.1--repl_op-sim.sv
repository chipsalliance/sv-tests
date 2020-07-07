/*
:name: repl_op_sim
:description: replication operator simulation test
:type: simulation parsing
:tags: 11.4.12.1
*/
module top();

bit [15:0] a;

bit [1:0] b = 2'b10;

initial begin
	a = {8{b}};
    $display(":assert: (0b1010101010101010 == %d)", a);
end

endmodule
