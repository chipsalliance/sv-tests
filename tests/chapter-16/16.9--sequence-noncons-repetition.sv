/*
:name: sequence_nonconsecutive_repetition_test
:description: sequence with nonconsecutive repetition operator test
:tags: 16.9
*/

module top();

logic clk;
logic a;
logic b;

sequence seq;
    @(posedge clk) b ##1 a [=2:10] ##1 b; //should be equal to: b ##1 a ##1 a ##1 a ##1 b
endsequence

assert property (seq);

endmodule
