/*
:name: interleaving_productions_rand_join_3
:description: rand join statement test
:tags: 18.17.5 uvm
*/

import uvm_pkg::*;
`include "uvm_macros.svh"

class env extends uvm_env;
  int x;

  function new(string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    begin
      randsequence( main )
        main : rand join (0.5) first second;
        first : { x = x + 20; };
        second : { x = x - 10; };
      endsequence

      if(x == 10) begin
        `uvm_info("RESULT", $sformatf("x = %0d SUCCESS", x), UVM_LOW);
      end else begin
        `uvm_error("RESULT", $sformatf("x = %0d FAILED", x));
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
