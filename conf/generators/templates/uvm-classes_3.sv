/*
:name: {0}_3
:description: {0} class test
:tags: uvm uvm-classes
:type: simulation parsing
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
