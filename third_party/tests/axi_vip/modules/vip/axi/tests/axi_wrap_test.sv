// -*- coding: utf-8 -*-
//
// Copyright (C) 2020 The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
// SPDX-License-Identifier: ISC

`ifndef _AXI_WRAP_TEST_SV_
`define _AXI_WRAP_TEST_SV_

class axi_wrap_test extends axi_base_test;
   `uvm_component_utils(axi_wrap_test)

   function new(string name = "axi_wrap_test", uvm_component parent = null);
      super.new(name,parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      configure_axi_env();
      configure_axi_cntrl();
   endfunction

   task run_phase(uvm_phase phase);
      super.run_phase(phase);

      uvm_test_done.drop_objection(this);
      uvm_test_done.set_drain_time(this, 1);
   endtask

   function void configure_axi_env();
      super.configure_axi_env();

      if (!axi_env_cfg.randomize())
         `uvm_fatal(tID, "axi_env_cfg Failed to Randomize")
      else begin
         `uvm_info(tID, $sformatf("%s", axi_env_cfg.sys_cfg.convert2string()), UVM_LOW)
         `uvm_info(tID, $sformatf("%s", axi_env_cfg.axim_agt_cfg.convert2string()), UVM_LOW)
         `uvm_info(tID, $sformatf("%s", axi_env_cfg.axis_agt_cfg.convert2string()), UVM_LOW)
      end
   endfunction

   function void configure_axi_cntrl();
      super.configure_axi_cntrl();

      axi_cntrl_cfg.min_wrap             = 1;
      axi_cntrl_cfg.max_wrap             = 1;

      axi_cntrl_cfg.rand_data_percent    = 100;
      axi_cntrl_cfg.incr_data_percent    = 0;
      axi_cntrl_cfg.const_data_percent   = 0;

      axi_cntrl_cfg.blk_size64_percent   = 100;
      axi_cntrl_cfg.blk_size512_percent  = 0;
      axi_cntrl_cfg.blk_size1024_percent = 0;
      axi_cntrl_cfg.blk_size2048_percent = 0;
      axi_cntrl_cfg.blk_size4096_percent = 0;

      if (!axi_cntrl_cfg.randomize())
         `uvm_fatal(tID, "axi_cntrl_cfg Failed to Randomize")
      else
         `uvm_info(tID, $sformatf("%s", axi_cntrl_cfg.convert2string()), UVM_LOW)
   endfunction

endclass
`endif
