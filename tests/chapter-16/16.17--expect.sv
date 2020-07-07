/*
:name: expect_test
:description: expect test
:tags: 16.17
*/

module top();

logic clk;
logic a;
logic b;

initial begin
    expect (@(posedge clk) a ##1 b);
end

endmodule
