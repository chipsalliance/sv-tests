/*
:name: sequence_test
:description: sequence test
:tags: 16.7
*/

module top();

logic clk;
logic a;
logic b;

sequence seq;
    @(posedge clk) a ##1 b;
endsequence

assert property (seq);

endmodule
