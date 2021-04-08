/*
:name: assign_in_exp
:description: assignment in expression test
:tags: 11.3.6
*/
module top();

int a;
int b;

initial begin
        b = (a-=1);
end

endmodule
