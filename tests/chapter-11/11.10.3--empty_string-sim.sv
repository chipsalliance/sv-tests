/*
:name: empty_string_sim
:description: empty string simulation test
:type: simulation parsing
:tags: 11.10.3
*/
module top();

bit [8*14:1] a;

initial begin
	a = "";
    $display(":assert: (1 == %d)", a == 0);
end

endmodule
