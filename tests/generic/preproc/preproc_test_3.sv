/*
:name: preproc_test_3
:description: Test
:should_fail: 0
:tags: 5.6.4
*/
`include `EXPAND_TO_STRING
`include `EXPAND_TO_PATH  // path
`define SANITY 1+1
`ifdef INSANITY
`undef INSANITY
`define INSANITY
`endif
