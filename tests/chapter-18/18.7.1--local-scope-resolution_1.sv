/*
:name: local_scope_resolution_1
:description: local:: scope resolution test
:tags: 18.7.1 uvm
*/

import uvm_pkg::*;
`include "uvm_macros.svh"

class a;
    rand int x;
endclass

function int F(a obj, int x);
    F = obj.randomize() with {x > 0; x < local::x; };
endfunction

class env extends uvm_env;

  a obj = new;
  int x;

  function new(string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    begin
      x = 10;
      F(obj, x);
      if(obj.x < x) begin
        `uvm_info("RESULT", $sformatf("obj.x = %0d x = %0d SUCCESS", obj.x, x), UVM_LOW);
      end else begin
        `uvm_info("RESULT", $sformatf("obj.x = %0d x = %0d FAILED", obj.x, x), UVM_LOW);
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
