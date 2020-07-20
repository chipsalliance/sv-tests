// -*- coding: utf-8 -*-
//
// Copyright (C) 2020 The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
// SPDX-License-Identifier: ISC

//==================================================================================
`ifndef _CTO_MONITOR_SVH_
`define _CTO_MONITOR_SVH_


class cto_monitor#(
                    parameter WAIT_NUM_CLKS = 50,
                    type     CFG_t = uvm_object
                   ) extends uvm_monitor;
   `uvm_component_param_utils(cto_monitor#(WAIT_NUM_CLKS, CFG_t))

   CFG_t   cfg;

   bit     heartbeat;
   string  tID;
   bit     ok_to_end;



   function new (string name = "cto monitor", uvm_component parent = null);
      super.new(name, parent);
      tID = get_name();
      tID = tID.toupper();
   endfunction // new



   function void build_phase(uvm_phase phase);
      super.build_phase(phase);

   endfunction

   task run_phase(uvm_phase phase);     
      fork
         forever begin
            @(posedge cfg.axi_vi.clk);
            `uvm_info(tID, $sformatf(" \n\t YAY CLOCK WORKING"), UVM_LOW)
         end
      join_none
   endtask // run_phase

endclass // cto_monitor


`endif
