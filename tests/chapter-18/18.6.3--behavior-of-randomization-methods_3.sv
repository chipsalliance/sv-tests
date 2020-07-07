/*
:name: behavior_of_randomization_methods_3
:description: If randomize() fails, post_randomize() is not called.
:tags: 18.6.3 uvm
*/

import uvm_pkg::*;
`include "uvm_macros.svh"

class a;
    rand int b;
    int d = 1;

    constraint c { b == 0 && b > 0; }

    function void post_randomize();
        d = 20;
    endfunction
endclass

class env extends uvm_env;

  a obj = new;
  int status;

  function new(string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    begin
      status = obj.randomize();

      if(status == 0 && obj.d == 1) begin
        `uvm_info("RESULT", $sformatf("obj.d = %0d SUCCESS", obj.d), UVM_LOW);
      end else begin
        `uvm_error("RESULT", $sformatf("obj.d = %0d FAILED", obj.d));
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
