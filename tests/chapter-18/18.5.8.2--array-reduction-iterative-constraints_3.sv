// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: array_reduction_iterative_constraints_3
:description: array reduction constraint over a dynamic array whose size is itself random (UVM runtime check)
:tags: uvm-random uvm
:timeout: 300
:unsynthesizable: 1
*/

import uvm_pkg::*;
`include "uvm_macros.svh"

class a;
    rand int unsigned n;
    rand int B[];
    constraint c_n    { n inside {[2:4]}; }
    constraint c_size { B.size() == n; }
    constraint c_elem { foreach (B[i]) B[i] inside {[0:50]}; }
    constraint c_sum  { B.sum() == 100; }
    constraint c_order { solve n before B; }
endclass

class env extends uvm_env;

  a obj = new;

  function new(string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    begin
      int ok = obj.randomize();
      if (ok == 1 && obj.B.sum() == 100 && obj.B.size() == obj.n) begin
        `uvm_info("RESULT", $sformatf(
            "n=%0d B=%p sum=%0d SUCCESS", obj.n, obj.B, obj.B.sum()), UVM_LOW);
      end else begin
        `uvm_error("RESULT", $sformatf(
            "ok=%0d n=%0d B=%p sum=%0d FAILED", ok, obj.n, obj.B, obj.B.sum()));
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
