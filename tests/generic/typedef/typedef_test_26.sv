/*
:name: typedef_test_26
:description: Test
:tags: 6.18
*/
typedef enum {
`ifdef TWO
  Global = 2,
`else
  Global = 1,
`endif
  Local = 3
} myenum_fwd;

module test;
endmodule
