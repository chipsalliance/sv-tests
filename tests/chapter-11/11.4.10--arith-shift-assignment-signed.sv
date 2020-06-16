/*
:name: arith_shift_assignment_signed
:description: arithmetic shift assignment operator test
:type: simulation parsing
:tags: 11.4.10
*/
module top();

logic signed [7:0] a, b, c;

initial begin
    a = -120; // 128 + 8
    b = a;
    c = a;
    b <<<= 3;
    c >>>= 3;

    $display(":assert: (  64 == %d)", b);
    $display(":assert: ( -15 == %d)", c);
end

endmodule
