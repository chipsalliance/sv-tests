// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: {0}_0
:description: {0} class test
:tags: uvm uvm-classes
:type: simulation elaboration parsing
:timeout: 300
:unsynthesizable: 1
*/

import uvm_pkg::*;
`include "uvm_macros.svh"

class C extends {0};

    function new(string name, uvm_component parent = null);
        super.new(name, parent);
        `uvm_info("RESULT", "new {0} created", UVM_LOW);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("RESULT", "build phase completed", UVM_LOW);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("RESULT", "connect phase completed", UVM_LOW);
    endfunction

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        `uvm_info("RESULT", "end of elaboration phase completed", UVM_LOW);
    endfunction

    virtual function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
        `uvm_info("RESULT", "start of simulation phase completed", UVM_LOW);
    endfunction

    task run_phase(uvm_phase phase);
        `uvm_info("RESULT", "run phase phase completed", UVM_LOW);
    endtask

    virtual function void extract_phase(uvm_phase phase);
        super.extract_phase(phase);
        `uvm_info("RESULT", "extract phase completed", UVM_LOW);
    endfunction

    virtual function void check_phase(uvm_phase phase);
        super.check_phase(phase);
        `uvm_info("RESULT", "check phase completed", UVM_LOW);
    endfunction

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("RESULT", "report phase completed", UVM_LOW);
    endfunction

endclass

module top;
    C obj;
    initial begin
        obj = new("C");
        run_test();
    end
endmodule
