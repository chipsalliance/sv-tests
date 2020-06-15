/*
:name: assignment_sim
:description: assignment simulation test
:type: simulation parsing
:tags: 11.4.1
*/
module top();
int a = 12;
int b = 5;
initial begin
    $display(":assert: (12 == %d)", a);
    a = b;
    $display(":assert: (5 == %d)", a);
end
endmodule
