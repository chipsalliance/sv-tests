/*
:name: class_member_test_27
:description: Test
:tags: 8.3
*/
class report_server; endclass
typedef int uvm_phase;

class myclass;
virtual function void starter(uvm_phase phase);
  report_server new_server = new;
endfunction : starter
endclass

module test;
endmodule
