// -*- coding: utf-8 -*-
//
// Copyright (C) 2020 The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
// SPDX-License-Identifier: ISC

`ifndef _TB_AXI_SEQ_SVH_
`define _TB_AXI_SEQ_SVH_

class tb_axi_seq extends uvm_sequence#(uvm_sequence_item, uvm_sequence_item);
   `uvm_object_utils(tb_axi_seq)

   axi_env_config     axi_env_cfg;
   axi_cntrl_config   axi_cntrl_cfg;

   sys_init_seq       sys_init_sq;
   axi_wrap_seq       axi_wrap_sq;

   function new(string name = "tb_axi_seq");
      super.new(name);
   endfunction

   task body();
      sys_init_sq = sys_init_seq::type_id::create("sys_init_sq");

      axi_wrap_sq               = axi_wrap_seq::type_id::create("axi_wrap_sq");
      axi_wrap_sq.axi_cntrl_cfg = this.axi_cntrl_cfg;

      sys_init_sq.start(axi_env_cfg.sys_cfg.sqr);

      axi_wrap_sq.start(axi_env_cfg.axim_agt_cfg.sqr);

      #5us;
   endtask

endclass
`endif
