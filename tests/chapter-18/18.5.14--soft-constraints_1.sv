/*
:name: soft_constraints_1
:description: soft constraints test
:tags: 18.5.14 uvm
*/

import uvm_pkg::*;
`include "uvm_macros.svh"

class a;
    rand int b;

    constraint c {
        soft b > 4;
        soft b < 12;
    }
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
      if(obj.b > 4 && obj.b < 12) begin
        `uvm_info("RESULT", $sformatf("obj.b = %0d SUCCESS", obj.b), UVM_LOW);
      end else begin
        `uvm_error("RESULT", $sformatf("obj.b = %0d FAILED", obj.b));
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
