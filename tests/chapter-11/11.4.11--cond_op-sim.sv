/*
:name: cond_op_sim
:description: ?: operator simulation test
:type: simulation parsing
:tags: 11.4.11
*/
module top();

int a = 12;
int b = 5;
int c;

initial begin
	c = (a > b) ? 11 : 13;
    $display(":assert: (11 == %d)", c);
end

endmodule
