/*
:name: preproc_test_13
:description: Test
:should_fail: 0
:tags: 5.6.4
*/
`define LONG_MACRO( \
    a, b="(3,2)", c=(3,2)) \
a + b /c +345
