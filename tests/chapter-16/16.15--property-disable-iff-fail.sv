/*
:name: property_disable_iff_fail_test
:description: failing property with disable iff
:should_fail_because: disable iff uses wrong reset polarity
:type: simulation
:tags: 16.15
*/

module clk_gen(
    input      rst,
    input      clk,
    output reg out
);

    initial begin
        out = 0;
    end

    always @(posedge clk or posedge rst) begin
        if (rst)
            out <= 0;
        else
            out <= 1;
    end

endmodule: clk_gen

module top();

    logic rst;
    logic clk;
    logic out;

    clk_gen dut(.rst(rst), .clk(clk), .out(out));

    initial begin
        clk   = 0;
        rst   = 1;
    end

    property prop;
        @(posedge clk) disable iff (~rst) out;
    endproperty

    assert property (prop) else $error($sformatf("property check failed :assert: (False)"));

    initial begin
        forever begin
            #(50) clk = ~clk;
        end
    end

    initial #1000 $finish;

endmodule
