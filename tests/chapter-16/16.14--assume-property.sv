/*
:name: assume_property_test
:description: assume property test
:tags: 16.14
*/
module top();

logic clk;
logic a;

assume property ( @(posedge clk) (a == 1));

endmodule
