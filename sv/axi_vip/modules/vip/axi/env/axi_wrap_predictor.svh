// -*- coding: utf-8 -*-
//
// Copyright (C) 2020 The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
// SPDX-License-Identifier: ISC

//==================================================================================
`ifndef _AXI_WRAP_PREDICTOR_SVH_
`define _AXI_WRAP_PREDICTOR_SVH_

class axi_wrap_predictor extends uvm_component;
   `uvm_component_utils(axi_wrap_predictor)

   string      tID;

   axi_trans   in_item, out_item;

   uvm_tlm_analysis_fifo #(axi_trans)   analysis_fifo;  // From monitor
   uvm_analysis_port #(axi_trans)       exp_ap, act_ap; // To scoreboard

   function new(string name = "wrap_predictor", uvm_component parent = null);
      super.new(name, parent);

      tID = get_name();
      tID = tID.toupper();
   endfunction

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      analysis_fifo = new("analysis_fifo",this);
      exp_ap        = new("exp_ap",this);
      act_ap        = new("act_ap",this);
      in_item       = new("in_item");
      out_item      = new("out_item");
   endfunction

   task run();
      get_trans();
   endtask

   task automatic get_trans();
      forever begin
         analysis_fifo.get(in_item);
         `uvm_info(tID,$sformatf ("in_item %s", in_item.convert2string()),UVM_MEDIUM)
         assert($cast(out_item, in_item.clone()));
         if (in_item.ttype == AXI_WR) begin //Only modify and send writes to predict side of wrap scoreboard
            out_item.wstrb.delete();
            out_item.ttype = AXI_RD;

            for (int i=0; i<(out_item.len+1)*BYTE_WIDTH; i++) begin
               out_item.rresp[i] = 'b0;
            end
            `uvm_info(tID,$sformatf ("exp out_item %s", out_item.convert2string()),UVM_MEDIUM)
            exp_ap.write(out_item);
         end
         else if (in_item.ttype == AXI_RD) begin //Only send reads to actual side of wrap scoreboard
            `uvm_info(tID,$sformatf ("act out_item %s", out_item.convert2string()),UVM_MEDIUM)
            act_ap.write(out_item);
         end
      end
   endtask

endclass
`endif
