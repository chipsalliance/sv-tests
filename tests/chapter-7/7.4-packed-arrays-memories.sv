/*
:name: Packed arrays
:description: Test packed arrays and memories support
:should_fail: 0
:tags: 7.4.3 7.4.4
*/
module top();

bit [7:0] b1;
bit [7:0] b2;

logic [7:0] mema [0:255];

initial begin
    b1 = 8'd0;
    b2 = 8'd0;
    $display(":assert:7.4.3: ((%d==0) and (%d==0))", b1, b2);

    b1 = 8'hde;
    b2 = 8'had;

    $display(":assert:7.4.3: (('%h' == 'de') and ('%h' == 'ad'))", b1, b2);

    b1 = b2;
    $display(":assert:7.4.3: ('%h' == '%h')", b1, b2);

    b1 = 8'h00;
    b2 = 8'hff;
    b2[4] = b1[4];
    $display(":assert:7.4.3: (%d == %d)", b1[4], b2[4]);

    $display(":assert:7.4.3: (%b == 0)", b1 == b2);
    $display(":assert:7.4.3: (%b == 1)", b1 != b2);
    b1 = b2;
    $display(":assert:7.4.3: (%b == 1)", b1 == b2);
    $display(":assert:7.4.3: (%b == 0)", b1 != b2);

    b2 = 8'd10;
    b1 = b2 + 3;
    $display(":assert:7.4.3: ((%d == 13) and (%d == 10))", b1, b2);

    mema[13] = 11;
    $display(":assert: 7.4.4: (%d == 11)", mema[13]);

    mema[11] = 13;
    $display(":assert: 7.4.4: (%d == 13)", mema[11]);
end

endmodule
