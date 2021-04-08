/*
:name: two_assignments_in_expression_sim
:description: assignment in expression simulation test
:type: simulation parsing
:tags: 11.3.6
*/
module top();

int a;
int b;
int c;
int d;
int e;

initial begin
        c = a;
        e = b;
        d = ((b += (a+=1) + 1));
        $display(":assert: (%d == %d)", b, (e+c+2));
        $display(":assert: (%d == %d)", d, (e+c+2));
end

endmodule
