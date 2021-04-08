/*
:name: assign_in_expression_sim
:description: assignment in expression simulation test
:type: simulation parsing
:tags: 11.3.6
*/
module top();

int a;
int b;
int c;

initial begin
        c = a;
        b = (++a);
        $display(":assert: (%d == %d)", b, (c+1));
end

endmodule
