/*
:name: typedef_test_17
:description: Test
:should_fail: 0
:tags: 6.18
*/
typedef struct packed {
  apkg::type_member #(N, M) [P:0] some_member;
} mystruct_t;