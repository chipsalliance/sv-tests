/*
:name: typedef_test_27
:description: Test
:tags: 6.18
*/
typedef enum {
  Global = 2,
`ifdef TWO
  Local = 2
`else
  Local = 1
`endif
} myenum_fwd;