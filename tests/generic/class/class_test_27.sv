/*
:name: class_test_27
:description: Test
:tags: 6.15 8.3
*/

package Package;
  interface class Bar #(parameter A, B); endclass
endpackage

class Foo implements Package::Bar#(1, 2); endclass