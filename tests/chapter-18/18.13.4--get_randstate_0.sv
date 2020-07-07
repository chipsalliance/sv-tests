/*
:name: get_randstate_0
:description: get_randstate() test
:tags: 18.13.4 uvm
*/

import uvm_pkg::*;
`include "uvm_macros.svh"

class a;
    rand int x;
endclass

class env extends uvm_env;

  a obj = new;
  string randstate;
  int ret;

  function new(string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    begin
      ret = obj.randomize();
      randstate = obj.get_randstate();

      if(ret == 1 && randstate != null) begin
        `uvm_info("RESULT", $sformatf("ret = %0d randstate = %s SUCCESS", ret, randstate), UVM_LOW);
      end else begin
        `uvm_error("RESULT", $sformatf("ret = %0d randstate = %s FAILED", ret, randstate));
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
