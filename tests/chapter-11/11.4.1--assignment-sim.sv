/*
:name: assignment_sim
:description: assignment simulation test
:type: simulation parsing
:tags: 11.4.1
*/
module top();
reg [3:0] a;
reg [3:0] b;
initial begin
    a = 4'd12;
    b = 4'd5;
    $display(":assert: (12 == %d)", a);
    a = b;
    $display(":assert: (5 == %d)", a);
end
endmodule
