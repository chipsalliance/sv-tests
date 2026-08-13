// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: uniqueness_constraints_3
:description: uniqueness constraints test - unique{} over an array (UVM runtime check)
:tags: uvm-random uvm
:timeout: 300
:unsynthesizable: 1
*/

import uvm_pkg::*;
`include "uvm_macros.svh"

class a;
    rand bit [3:0] tags[6];
    constraint c1 { unique {tags}; }
endclass

class env extends uvm_env;

  a obj = new;

  function new(string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    begin
      bit dup_found = 0;
      int ok = obj.randomize();
      for (int i = 0; i < 6; i++)
        for (int j = i+1; j < 6; j++)
          if (obj.tags[i] == obj.tags[j]) dup_found = 1;

      if (ok == 1 && dup_found == 0) begin
        `uvm_info("RESULT", $sformatf("tags = %p SUCCESS", obj.tags), UVM_LOW);
      end else begin
        `uvm_error("RESULT", $sformatf(
            "tags = %p ok=%0d dup_found=%0d FAILED", obj.tags, ok, dup_found));
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
