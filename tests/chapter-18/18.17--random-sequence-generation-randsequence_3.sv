/*
:name: random-sequence-generation-randsequence_3
:description: randsequence test
:tags: 18.17 uvm
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
        main : first | second;
        first : { x = -2; };
        second : { x = 2; };
      endsequence

      if(x == 2 || x == -2) begin
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
