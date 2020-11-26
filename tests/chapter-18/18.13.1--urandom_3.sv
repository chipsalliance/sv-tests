/*
:name: urandom_3
:description: urandom() test
:tags: uvm-18.13.1 uvm
*/

import uvm_pkg::*;
`include "uvm_macros.svh"

class a;
    function int unsigned do_urandom(int seed);
        int unsigned x;
        x = $urandom(seed);
        return x;
    endfunction
endclass

class env extends uvm_env;

  a obj = new;
  int unsigned ret1, ret2;
  int seed = 254;

  function new(string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    begin
      ret1 = obj.do_urandom(seed);
      ret2 = obj.do_urandom(seed);
      if(ret1 == ret2) begin
        `uvm_info("RESULT", $sformatf("ret1 = %0d ret2 = %0d SUCCESS", ret1, ret2), UVM_LOW);
      end else begin
        `uvm_error("RESULT", $sformatf("ret1 = %0d ret2 = %0d FAILED", ret1, ret2));
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
