/*
:name: class_test_29
:description: Test
:tags: 6.15 8.3
*/

package Pkg;
  interface class Bar; endclass
endpackage

class Base; endclass
interface class Baz; endclass

class Foo extends Base implements Pkg::Bar, Baz; endclass