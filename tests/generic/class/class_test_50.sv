/*
:name: class_test_50
:description: Test
:should_fail: 0
:tags: 6.15 8.3
*/
class params_as_class_item;
  localparam M = {"hello", "world"}, X = "spot";
  parameter int N = 2, P = Q(R), S = T[U];
endclass