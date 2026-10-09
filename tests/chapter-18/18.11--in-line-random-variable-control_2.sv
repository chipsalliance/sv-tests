// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: in-line_random_variable-control_2
:description: randomize(variable_identifier_list) should hold other rand variables as state
:tags: uvm-random uvm
:timeout: 300
:unsynthesizable: 1
*/

import uvm_pkg::*;
`include "uvm_macros.svh"

class a;
    rand int x;
    rand int y;
endclass

class env extends uvm_env;

  a obj = new;

  function new(string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    begin
      int y_before;
      int ok;
      obj.x = 5;
      obj.y = 100;
      y_before = obj.y;
      ok = obj.randomize(x);

      if (ok == 1 && obj.y == y_before) begin
        `uvm_info("RESULT", $sformatf(
            "x=%0d y_before=%0d y_after=%0d SUCCESS", obj.x, y_before, obj.y), UVM_LOW);
      end else begin
        `uvm_error("RESULT", $sformatf(
            "x=%0d y_before=%0d y_after=%0d FAILED -- randomize(x) should not have changed y",
            obj.x, y_before, obj.y));
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
