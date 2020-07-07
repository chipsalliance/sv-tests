/*
:name: unary_op_dec_sim
:description: -- operator simulation test
type: simulation parsing
:tags: 11.4.2
*/
module top();

int a = 12;

initial begin
	a--;
    $display(":assert: (11 == %d)", a);
end

endmodule
