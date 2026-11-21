// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: uniqueness_constraints_5
:description: uniqueness constraints test - unique{} over a row of a 2D array (UVM runtime check)
:tags: uvm-random uvm
:timeout: 300
:unsynthesizable: 1
*/

import uvm_pkg::*;
`include "uvm_macros.svh"

class a;
    rand bit [4:0] grid[3][3];
    constraint c1 { foreach (grid[i,j]) grid[i][j] inside {[1:9]}; }
    constraint c2 { foreach (grid[i]) unique {grid[i]}; }
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
      for (int i = 0; i < 3; i++)
        for (int j = 0; j < 3; j++)
          if (obj.grid[i][0] == obj.grid[i][1] ||
              obj.grid[i][1] == obj.grid[i][2] ||
              obj.grid[i][0] == obj.grid[i][2])
            dup_found = 1;

      if (ok == 1 && dup_found == 0) begin
        `uvm_info("RESULT", $sformatf("grid = %p SUCCESS", obj.grid), UVM_LOW);
      end else begin
        `uvm_error("RESULT", $sformatf(
            "grid = %p ok=%0d dup_found=%0d FAILED", obj.grid, ok, dup_found));
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
