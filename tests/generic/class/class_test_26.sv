/*
:name: class_test_26
:description: Test
:tags: 6.15 8.3
*/
interface class Bar #(parameter N); endclass

parameter int N = 1;
class Foo implements Bar#(N); endclass

module test;
endmodule
