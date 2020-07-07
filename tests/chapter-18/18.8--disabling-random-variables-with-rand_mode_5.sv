/*
:name: disabling-random-variables-with-rand_mode_5
:description: rand_mode() test
:should_fail_because: The rand_mode() method is built-in and cannot be overridden.
:tags: 18.8 uvm
*/

import uvm_pkg::*;
`include "uvm_macros.svh"

class a;
    rand int x;
    function int rand_mode();
        return 1;
    endfunction
endclass

class env extends uvm_env;

  a obj = new;
  int ret;

  function new(string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    begin
      ret = obj.x.rand_mode();

      if(ret == 1) begin
        `uvm_info("RESULT", $sformatf("ret = %0d SUCCESS", ret), UVM_LOW);
      end else begin
        `uvm_error("RESULT", $sformatf("ret = %0d FAILED", ret));
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
