/*
:name: set_member_sim
:description: inside operator simulation test
:type: simulation parsing
:tags: 11.4.13
*/
module top();

int a = 12;

initial begin
    $display(":assert: (1 == %d)", a inside {2, 4, 6, 8, 10, 12});
end

endmodule
