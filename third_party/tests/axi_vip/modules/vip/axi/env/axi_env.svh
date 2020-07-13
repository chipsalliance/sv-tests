// -*- coding: utf-8 -*-
//
// Copyright (C) 2020 The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
// SPDX-License-Identifier: ISC

`ifndef _AXI_ENV_SVH_
`define _AXI_ENV_SVH_

class axi_env extends uvm_env;
   `uvm_component_utils(axi_env)

   axi_env_config       axi_env_cfg;
   sys_agent            sys_agt;
   axi_agent            axim_agt, axis_agt;
   axi_wrap_predictor   wrap_pdr;

   base_scoreboard#(.trans_type(axi_trans), .INORDER(1))   wrap_sb;

   function new(string name = "axi_env", uvm_component parent);
      super.new(name, parent);
   endfunction

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      sys_agt      = sys_agent::type_id::create("sys_agt", this);
      sys_agt.cfg  = axi_env_cfg.sys_cfg;

      axim_agt     = axi_agent#()::type_id::create("axim_agt", this);
      axim_agt.cfg = axi_env_cfg.axim_agt_cfg;

      axis_agt     = axi_agent#()::type_id::create("axis_agt", this);
      axis_agt.cfg = axi_env_cfg.axis_agt_cfg;

      wrap_sb      = base_scoreboard#(axi_trans, 1)::type_id::create("wrap_sb", this);

      wrap_pdr     = axi_wrap_predictor::type_id::create("wrap_pdr", this);
   endfunction

   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);

      axim_agt.mon_ap.connect(wrap_pdr.analysis_fifo.analysis_export);
      wrap_pdr.exp_ap.connect(wrap_sb.exp_ae);
      wrap_pdr.act_ap.connect(wrap_sb.act_ae);
   endfunction

endclass
`endif
