// -*- coding: utf-8 -*-
//
// Copyright (C) 2020 The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
// SPDX-License-Identifier: ISC

`ifndef _SYS_AGENT_SVH_
`define _SYS_AGENT_SVH_

class sys_agent extends uvm_agent;
   `uvm_component_utils(sys_agent)

   sys_config                     cfg;

   sys_driver                     drv;
   sys_monitor                    mon;

   uvm_analysis_port#(sys_trans)  ap;

   function new(string name = "sys_agent", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      mon     = sys_monitor::type_id::create("mon", this);
      mon.cfg = cfg;

      drv     = sys_driver::type_id::create("drv", this);
      drv.cfg = cfg;

      cfg.sqr = sys_sequencer::type_id::create("cfg.sqr", this);

      ap = new("ap",this);
   endfunction

   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);

      mon.ap.connect(ap);
      drv.seq_item_port.connect(cfg.sqr.seq_item_export);
   endfunction

endclass
`endif
