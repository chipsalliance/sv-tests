/*
:name: assign_in_expr_sim
:description: assignment in expression simulation test
:type: simulation parsing
:tags: 11.3.6
*/
module top();

int a;
int b;
int c;

initial begin
	a = (b = (c = 5));	
    $display(":assert: (5 == %d)", a);
    $display(":assert: (5 == %d)", b);
    $display(":assert: (5 == %d)", c);
end

endmodule
