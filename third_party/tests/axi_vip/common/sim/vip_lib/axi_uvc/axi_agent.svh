// -*- coding: utf-8 -*-
//
// Copyright (C) 2020 The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
// SPDX-License-Identifier: ISC

`ifndef _AXI_AGENT_SVH_
`define _AXI_AGENT_SVH_

class axi_agent#(
                 parameter ID_WIDTH   = 16,
                 parameter ADDR_WIDTH = 64,
                 parameter BYTE_WIDTH = 32,
                 parameter USER_WIDTH = 4
                ) extends uvm_agent;
   `uvm_component_param_utils(axi_agent#(ID_WIDTH, ADDR_WIDTH, BYTE_WIDTH, USER_WIDTH))

   string          tID;

   axi_agent_config#(
                    .ID_WIDTH     (ID_WIDTH  ),
                    .ADDR_WIDTH   (ADDR_WIDTH),
                    .BYTE_WIDTH   (BYTE_WIDTH),
                    .USER_WIDTH   (USER_WIDTH)
                    )   cfg;

   axi_monitor     #(
                    .ID_WIDTH     (ID_WIDTH  ),
                    .ADDR_WIDTH   (ADDR_WIDTH),
                    .BYTE_WIDTH   (BYTE_WIDTH),
                    .USER_WIDTH   (USER_WIDTH)
                    )   mon;

   axi_driver      #(
                    .ID_WIDTH     (ID_WIDTH  ),
                    .ADDR_WIDTH   (ADDR_WIDTH),
                    .BYTE_WIDTH   (BYTE_WIDTH),
                    .USER_WIDTH   (USER_WIDTH)
                    )   drv;

   axi_sequencer   sqr;

   axis_memory     #(
                     .BYTE_WIDTH(BYTE_WIDTH)
                    )   mem;

   uvm_analysis_port#(axi_trans)   drv_ap, mon_ap;

   function new(string name =  "axi_agent" , uvm_component parent = null);
      super.new(name, parent);

      tID = get_full_name();
      tID = tID.toupper();
   endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      assert (cfg != null) else
         `uvm_error(tID, "axi_agt.cfg is null")

      mem = axis_memory#(
                         .BYTE_WIDTH(BYTE_WIDTH)
                        )::type_id::create("mem", this);

      // Both monitor and driver always present (for slave responses)
      mon = axi_monitor#(
                         .ID_WIDTH     (ID_WIDTH  ),
                         .ADDR_WIDTH   (ADDR_WIDTH),
                         .BYTE_WIDTH   (BYTE_WIDTH),
                         .USER_WIDTH   (USER_WIDTH)
                        )::type_id::create("axi_mon", this);

      drv = axi_driver#(
                        .ID_WIDTH     (ID_WIDTH  ),
                        .ADDR_WIDTH   (ADDR_WIDTH),
                        .BYTE_WIDTH   (BYTE_WIDTH),
                        .USER_WIDTH   (USER_WIDTH)
                       )::type_id::create("axi_drv", this);

      sqr = axi_sequencer::type_id::create("sqr", this);

      drv_ap = new("drv_ap",this);
      mon_ap = new("mon_ap",this);
   endfunction

   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);

      drv.seq_item_port.connect(sqr.seq_item_export);
      mon.rsp_ap.connect(drv.analysis_fifo.analysis_export);
      mon.ap.connect(mon_ap);
      drv.ap.connect(drv_ap);

      cfg.sqr = this.sqr;

      drv.cfg = this.cfg;

      mon.cfg = this.cfg;
      mon.mem = this.mem;
   endfunction

endclass
`endif
