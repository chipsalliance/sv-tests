/*
:name: wrong-identifiers
:description: Identifiers that should not be accepted
:should_fail_because: Identifiers that should not be accepted
:tags: 5.6
*/
module identifiers();
  reg $dollar;
  reg 0number;
endmodule
