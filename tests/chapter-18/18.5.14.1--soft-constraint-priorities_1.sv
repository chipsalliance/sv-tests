/*
:name: soft_constraint_priorities_1
:description: soft constraint priorities test
:tags: 18.5.14.1 uvm
*/

import uvm_pkg::*;
`include "uvm_macros.svh"

class a1;
    rand int b;

    constraint c1 {
        soft b > 4;
        soft b < 12; }
endclass

class a2 extends a1;
    constraint c2 { soft b == 20; }
endclass

class env extends uvm_env;

  a2 obj = new;

  function new(string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    begin
      obj.randomize();
      if(obj.b == 20) begin
        `uvm_info("RESULT", $sformatf("obj.b = %0d SUCCESS", obj.b), UVM_LOW);
      end else begin
        `uvm_info("RESULT", $sformatf("obj.b = %0d FAILED", obj.b), UVM_LOW);
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
