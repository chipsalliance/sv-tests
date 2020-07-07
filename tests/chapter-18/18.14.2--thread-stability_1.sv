/*
:name: thread_stability_1
:description: thread stability test
:tags: 18.14.2 uvm
*/

import uvm_pkg::*;
`include "uvm_macros.svh"

class env extends uvm_env;
  int unsigned val1, val2;
  process p1, p2;
  string randstate1, randstate2;

  function new(string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    begin

      fork
        begin
            p1 = process::self();
            randstate1 = p1.get_randstate();
            val1 = $urandom;
        end
        begin
            p2 = process::self();
            randstate2 = p2.get_randstate();
            val2 = $urandom;
        end
      join

      if(val1 != val2 && randstate1 != randstate2) begin
        `uvm_info("RESULT", $sformatf("val1 = %0d val2 = %0d SUCCESS", val1, val2), UVM_LOW);
      end else begin
        `uvm_error("RESULT", $sformatf("val1 = %0d val2 = %0d FAILED", val1, val2));
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
