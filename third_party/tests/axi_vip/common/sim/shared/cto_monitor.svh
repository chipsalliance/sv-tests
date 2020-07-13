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
      //super.run_phase(phase);
      fork
         forever begin           
            @(posedge cfg.axi_vi.clk);
            `uvm_info(tID, $sformatf(" \n\t YAY CLOCK WORKING"), UVM_LOW)
         end
      join_none
         
         
   endtask // run_phase

   
  //function void phase_ready_to_end(uvm_phase phase);
  //   uvm_phase current_phase;
  //   string str ="";
  //   uvm_object objectors[$];
  //   current_phase = phase;
  //
  //
  //   if (phase.is(uvm_main_phase::get())) begin  // check if we are in the main phase (better than just checking for run)     
  //      // Start heatbeat monitor
  //        `uvm_info(tID, $sformatf(" \n\t ----| Heartbeat Monitor Started |----"), UVM_LOW);
  //      fork
  //         check_for_heartbeat();
  //      join_none;
  //      if (!ok_to_end) begin
  //         `uvm_info(tID, $sformatf("\n\t ----RAISING OBJECTION  IN HEARTBEAT MONITOR----"), UVM_LOW)
  //         phase.raise_objection(this);
  //         fork begin
  //            wait_for_ok_end();
  //            phase.drop_objection(this);
  //
  //            // see who is still objecting
  //            current_phase.get_objection().get_objectors(objectors); // get all that has raised objections
  //            str = $sformatf("\n\n\t |--------------------| Who Is Still OBJECTNG |------------------------|"); 
  //            str = {str, $sformatf("\n\t  current phase: %s ", current_phase.get_name())};
  //            str = {str, $sformatf("\n\t Hierarchical Name                                              Class Type")};
  //            foreach(objectors[i]) begin
  //               str = {str, $sformatf("\n\t%-60s%s\n\n", objectors[i].get_full_name(), objectors[i].get_type_name())};
  //            end
  //            `uvm_info({tID, "*"}, str, UVM_HIGH);
  //         end join_none;
  //      end
  //   end
  //endfunction
  //
  ////-----------------------
  //// Wait until ok_to_end is set. Only checks ok_to_end every WAIT_NUM_CLK cycle since this is the length of the heartbeat cycle
  //task wait_for_ok_end();
  //   forever begin
  //      `uvm_info(tID, $sformatf("\n\t checking for heartbeat in intervals of %d",WAIT_NUM_CLKS), UVM_LOW)
  //      repeat(WAIT_NUM_CLKS) @(posedge clk);
  //      `uvm_info(tID, $sformatf("nt ----~is it ok to end: %b", ok_to_end), UVM_LOW)
  //      if (ok_to_end) break;
  //   end
  //endtask // wait_for_ok_end
  //
  //// Waits WAIT_NUM_CLK while checking if there is any data on the interface. If there is then !ok_to_end else ok_to_end.
  //task check_for_heartbeat();
  //
  //   bit     hb_detected = 0;      
  //   fork
  //      begin
  //         `uvm_info(tID, $sformatf("\n\t running check_heartbeat"), UVM_LOW)
  //         forever begin         
  //            @(posedge clk);
  //            `uvm_info(tID, $sformatf("\n\t detecting heartbeats"), UVM_LOW)
  //            if(heartbeat) begin     
  //               `uvm_info(tID, $sformatf("heartbeat detected"), UVM_LOW)
  //               hb_detected = 1;
  //            end          
  //         end
  //      end
  //      begin
  //         forever begin
  //            ok_to_end = 0;
  //            `uvm_info(tID, $sformatf("\n\t check if heartbeat was found"), UVM_LOW)
  //            repeat(WAIT_NUM_CLKS) @(posedge clk);
  //            `uvm_info(tID, $sformatf("\n\t after_repeat"), UVM_LOW)
  //            if(!hb_detected) begin
  //               ok_to_end = 1;
  //               `uvm_info(tID, $sformatf("\n\t ----| OK TO END | ----"), UVM_LOW)
  //               break;
  //            end else begin
  //               `uvm_info(tID, $sformatf(" \n\t ----|heartbeat detected - Resetting timer|----"), UVM_LOW);
  //               hb_detected = 0;
  //            end          
  //         end
  //      end        
  //   join_any
  //endtask
endclass // cto_monitor


`endif
