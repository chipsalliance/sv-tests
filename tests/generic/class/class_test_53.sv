/*
:name: class_test_53
:description: Test
:tags: 6.15 8.3
*/
package mypkg;
  typedef int GlueType;
  class ModuleType #(parameter A); endclass
endpackage

typedef int BrickType;
typedef int Ctype1;
typedef int Ctype2;

parameter int N = 1;
parameter int M = 2;

class param_types_as_class_item;
  parameter type AT = int;
  parameter type BT = BrickType;
  parameter type CT1 = Ctype1, CT2 = Ctype2;
  localparam type GT = mypkg::GlueType, GT2 = int;
  localparam type HT1 = int, HT2 = mypkg::ModuleType#(N+M);
endclass

module test;
endmodule
