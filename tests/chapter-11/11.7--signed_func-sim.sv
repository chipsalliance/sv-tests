/*
:name: signed_func_sim
:description: $signed() simulation test
:type: simulation parsing
:tags: 11.7
*/
module top();

logic signed [7:0] a;

initial begin
	a = $signed(4'b1000);
    $display(":assert: (-8 == %d)", a);
end

endmodule
