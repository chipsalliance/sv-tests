/*
:name: manually_seeding_randomize_1
:description: manually seeding randomize test
:tags: 18.15 uvm
*/

import uvm_pkg::*;
`include "uvm_macros.svh"

class a;
    rand int x;
    function new (int seed);
        this.srandom(seed);
    endfunction
endclass

class env extends uvm_env;
  a obj = new(100);
  int prev_x;

  function new(string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    begin
      obj.randomize();
      prev_x = obj.x;
      obj.srandom(100);
      obj.randomize();

      if(obj.x == prev_x) begin
        `uvm_info("RESULT", $sformatf("obj.x = %0d prev_x = %0d SUCCESS", obj.x, prev_x), UVM_LOW);
      end else begin
        `uvm_error("RESULT", $sformatf("obj.x = %0d prev_x = %0d FAILED", obj.x, prev_x));
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
