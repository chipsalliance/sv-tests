/*
:name: real-constants-illegal
:description: Examples of real literal constants
:should_fail_because: Real literal constants must have at least one digit on each side of the decimal point
:tags: 5.7.2
*/
module top();
  logic [31:0] a;

  initial begin;
    a = .12;
    a = 9.;
    a = 4.E3;
    a = .2e-7;
  end

endmodule
