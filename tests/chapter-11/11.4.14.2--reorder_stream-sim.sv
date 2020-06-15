/*
:name: reorder_stream_sim
:description: stream reordering simulation test
:type: simulation parsing
:tags: 11.4.14.2
*/
module top();

int a = {"A", "B", "C", "D"};
int b;

initial begin
	b = {<< 8 {a}};
    $display(":assert: (0x44434241 == 0x%x)", b);
end

endmodule
