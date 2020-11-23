/*
:name: urandom_1
:description: urandom() test
:tags: uvm-18.13.1 uvm
*/

import uvm_pkg::*;
`include "uvm_macros.svh"

class a;
    function int unsigned do_urandom();
        int unsigned x;
        x = $urandom();
        return x;
    endfunction
endclass

class env extends uvm_env;

  a obj = new;
  int unsigned ret;

  function new(string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    begin
      ret = obj.do_urandom();
      if(ret >= 0) begin
        `uvm_info("RESULT", $sformatf("ret = %0d SUCCESS", ret), UVM_LOW);
      end else begin
        `uvm_error("RESULT", $sformatf("ret = %0d FAILED", ret));
      end
    end
    phase.drop_objection(this);
  endtask: run_phase
  
endclass

module top;

  env environment;

  initial begin
    environment = new("env");
    run_test();
  end
  
endmodule
