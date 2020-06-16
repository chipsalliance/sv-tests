/*
:name: unpack_stream_sim
:description: stream unpack simulation test
:type: simulation parsing
:tags: 11.4.14.3
*/
module top();

int a = 1;
int b = 2;
int c = 3;

initial begin
	bit [95:0] d = {<< 32 {a, b, c}};
    $display(":assert: (((%d << 64) + (%d << 32) + %d) == %d)", c, b, a, d);
end

endmodule
