/*
:name: uvm_scoreboard_env
:description: uvm scoreboard + env test
:tags: uvm uvm-scoreboards
:type: simulation parsing
:timeout: 30
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

class packet_out extends uvm_sequence_item;
    logic [7:0] data;

    `uvm_object_utils_begin(packet_out)
        `uvm_field_int(data, UVM_ALL_ON|UVM_HEX)
    `uvm_object_utils_end

    function new(string name="packet_out");
        super.new(name);
    endfunction: new
endclass

class comparator #(type T = packet_out) extends uvm_scoreboard;
    typedef comparator #(T) this_type;
    `uvm_component_param_utils(this_type)
    int match, mismatch;

    const static string type_name = "comparator #(T)";

    uvm_analysis_imp #(T, this_type) from_dut;

    typedef uvm_built_in_converter #( T ) convert;

    event end_of_simulation;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        from_dut = new("from_dut", this);
        match = 0;
        mismatch = 0;
    endfunction

    virtual function string get_type_name();
        return type_name;
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        @(end_of_simulation);
        phase.drop_objection(this);
    endtask

    virtual function void write(T rec);
        if(rec.data == `PATTERN) begin
          `uvm_info("RESULT", $sformatf("Comparator match %d == %d", rec.data, `PATTERN), UVM_LOW);
          match++;
        end
        else begin
          `uvm_error("RESULT", $sformatf("Comparator mismatch %d != %d", rec.data, `PATTERN));
          mismatch++;
        end
        -> end_of_simulation;
  endfunction
endclass

class env extends uvm_env;
    comparator #(packet_out) comp;  
    virtual input_if in_vif;
    virtual output_if out_vif;
    packet_out packet;

    `uvm_component_utils(env)

    uvm_analysis_port #(packet_out) item_collected_port;

    function new(string name, uvm_component parent = null);
        super.new(name, parent);
        item_collected_port = new("item_collected_port", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        comp = comparator#(packet_out)::type_id::create("comp", this);
        packet = packet_out::type_id::create("packet", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        assert(uvm_resource_db#(virtual input_if)::read_by_name(
          get_full_name(), "input_if", in_vif));
        assert(uvm_resource_db#(virtual output_if)::read_by_name(
          get_full_name(), "output_if", out_vif));
        item_collected_port.connect(comp.from_dut);
    endfunction

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
    endfunction

    task run_phase(uvm_phase phase);
        `uvm_info("RESULT", $sformatf("Writing %0d to input interface", `PATTERN), UVM_LOW);
        in_vif.data <= `PATTERN;
        repeat(2) @(posedge out_vif.clk);
        packet.data = out_vif.data;
        item_collected_port.write(packet);
    endtask

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
    endfunction
endclass

module top;
    logic clk;
    env environment;

    input_if in(clk);
    output_if out(clk);
    dut d(in, out);

    always #5 clk = !clk;

    initial begin
        environment = new("env");
        uvm_resource_db#(virtual input_if)::set("env", "input_if", in);
        uvm_resource_db#(virtual output_if)::set("env",  "output_if", out);
        clk = 0;
        run_test();
    end
endmodule
