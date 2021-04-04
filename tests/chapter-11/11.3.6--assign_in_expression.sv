/*
:name: assign_in_expression
:description: assignment in expression test
:tags: 11.3.6
*/
module top();

int a;
int b;

initial begin
        b = (++a);
end

endmodule
