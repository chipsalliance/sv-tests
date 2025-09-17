// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: {0}_1
:description: {0} class test
:tags: uvm uvm-classes
:type: simulation elaboration parsing
:timeout: 300
:unsynthesizable: 1
*/

import uvm_pkg::*;
`include "uvm_macros.svh"

`define PATTERN 2

interface input_if(input clk);
    logic [7:0] data;
    modport port(input clk, data);
endinterface

interface output_if(input clk);
    logic [7:0] data;
    modport port(input clk, output data);
endinterface

module dut(input_if.port in, output_if.port out);
    always @(posedge in.clk)
        out.data <= in.data;
endmodule

class C extends {0};
    virtual output_if out_vif;
    virtual input_if in_vif;

    `uvm_component_utils(C)

    function new(string name, uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        assert(uvm_resource_db#(virtual input_if)::read_by_name(
            "C", "input_if", in_vif));
        assert(uvm_resource_db#(virtual output_if)::read_by_name(
            "C", "output_if", out_vif));
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        `uvm_info("RESULT", $sformatf("Writing %0d to input interface", `PATTERN), UVM_LOW);
        in_vif.data <= `PATTERN;
        repeat(2) @(posedge out_vif.clk);
        if(out_vif.data == `PATTERN) begin
            `uvm_info("RESULT", $sformatf("Match %d == %d",
                out_vif.data, `PATTERN), UVM_LOW);
        end
        else begin
            `uvm_error("RESULT", $sformatf("Mismatch %d != %d",
                out_vif.data, `PATTERN));
        end
        phase.drop_objection(this);
    endtask
endclass

module top;
    logic clk;
    C obj;
    input_if in(clk);
    output_if out(clk);
    dut d(in, out);

    always #5 clk = !clk;

    initial begin
        obj = new("C");
        uvm_resource_db#(virtual input_if)::set("C","input_if", in);
        uvm_resource_db#(virtual output_if)::set("C", "output_if", out);
        clk = 0;
        run_test();
    end
endmodule
