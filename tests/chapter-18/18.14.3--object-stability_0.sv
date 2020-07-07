/*
:name: object_stability_0
:description: object stability test
:tags: 18.14.3 uvm
*/

import uvm_pkg::*;
`include "uvm_macros.svh"

class a1;
    rand int x;
endclass

class a2;
    rand int y;
endclass

class env extends uvm_env;
  a1 obj1 = new();
  a2 obj2 = new();
  string randstate1, randstate2;

  function new(string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    begin
      randstate1 = obj1.get_randstate();
      randstate2 = obj2.get_randstate();
      obj1.randomize();
      obj2.randomize();

      if(obj1.x != obj2.y && randstate1 != randstate2) begin
        `uvm_info("RESULT", $sformatf("obj1.x = %0d obj2.y = %0d SUCCESS", obj1.x, obj2.y), UVM_LOW);
      end else begin
        `uvm_error("RESULT", $sformatf("obj1.x = %0d obj2.y = %0d FAILED", obj1.x, obj2.y));
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
