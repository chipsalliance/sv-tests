// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: {0}_3
:description: {0} class test
:tags: uvm uvm-classes
:type: simulation elaboration parsing
:timeout: 500
:unsynthesizable: 1
*/

import uvm_pkg::*;
`include "uvm_macros.svh"

class C extends {0};
    `uvm_component_utils(C)

    function new(string name, uvm_component parent = null);
        super.new(name, parent);
        `uvm_info("RESULT", "Created new {0}", UVM_LOW);
    endfunction
endclass

module top;
    C obj;

    initial begin
        obj = new("C");
    end
endmodule
