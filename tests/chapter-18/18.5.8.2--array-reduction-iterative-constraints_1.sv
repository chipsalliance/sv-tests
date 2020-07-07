/*
:name: array_reduction_iterative_constraints_1
:description: array reduction iterative constraints test
:tags: 18.5.8.2 uvm
*/

import uvm_pkg::*;
`include "uvm_macros.svh"

class a;
    rand int B[5];
    constraint c { B.sum() == 5; }
endclass

class env extends uvm_env;

  a obj = new;

  function new(string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    begin
      obj.randomize();
      if(obj.B.sum() == 5) begin
        `uvm_info("RESULT", $sformatf("sum = %0d SUCCESS", obj.B.sum()), UVM_LOW);
      end else begin
        `uvm_error("RESULT", $sformatf("sum = %0d FAILED", obj.B.sum()));
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
