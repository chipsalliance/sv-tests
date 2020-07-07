/*
:name: adding_constraints_to_scope_variables_1
:description: Adding constraints to scope variables—std::randomize() with - test
:tags: 18.12.1 uvm
*/

import uvm_pkg::*;
`include "uvm_macros.svh"

class a;
    function int do_randomize(int y);
        int x, success;
        success = std::randomize(x) with {x > 0; x < y;};
        return success;
    endfunction
endclass

class env extends uvm_env;

  a obj = new;
  int ret, y = 20;

  function new(string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    begin
      ret = obj.do_randomize(y);
      if(ret == 1) begin
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
