/*
:name: typedef_test_28
:description: Test
:should_fail: 1
:tags: 6.18
*/

// 6.18 says:
// The actual data type definition of a forward typedef declaration shall
// be resolved within the same localscope or generate block. It shall be an
// error if the type_identifier does not resolve to a data type.

typedef missing_forward_typedef;