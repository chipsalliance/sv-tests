// -*- coding: utf-8 -*-
//
// Copyright (C) 2020 The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
// SPDX-License-Identifier: ISC

`ifndef _AXI_BASE_TEST_SV_
`define _AXI_BASE_TEST_SV_

class axi_base_test extends uvm_test;
   `uvm_component_utils(axi_base_test)

   string             tID;

   axi_env            axi_e;
   axi_env_config     axi_env_cfg;
   axi_cntrl_config   axi_cntrl_cfg;

   tb_axi_seq         tb_axi_sq;

   //**** Required code for report server ****
   custom_report_server  report_server;
   uvm_report_object     report_object;
   uvm_table_printer     printer;
   string                verb_level_str;
   int                   verb_level = UVM_LOW;
   int                   fwidth,hwidth;
   //*****************************************

   function new(string name = "axi_base_test", uvm_component parent = null);
      super.new(name,parent);

      tID = get_name();
      tID = tID.toupper();
   endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      // Create axi env and container sequence
      axi_e     = axi_env::type_id::create("axi_e",this);
      tb_axi_sq = tb_axi_seq::type_id::create("tb_axi_sq");

      // Configure the environment
      configure_axi_env();
      configure_axi_cntrl();

      //***** Use Customized report server *****
      report_server = custom_report_server::type_id::create("report_server");
      uvm_pkg::uvm_report_server::set_server(report_server);
      //****************************************

      // Set the watchdog timer - do not change the value here, override in testcase.
      uvm_top.set_timeout(1000000000); //1M ns
      // Create a specific depth printer for printing the created topology
      printer = new();
      uvm_test_done.raise_objection(this);
   endfunction

   task run_phase(uvm_phase phase);
      super.run_phase(phase);

      tb_axi_sq.start(null);
   endtask

   virtual function void report_phase(uvm_phase phase);
      print_test_vitals();
   endfunction

   // Print out vital info based on TestCase info
   function void print_test_vitals ();
      string tc_name = "INVALID TESTCASE";
      int    tc_seed = -1;

      if ($value$plusargs("UVM_TESTNAME=%s", tc_name))
      `uvm_info(tID,{$sformatf("print_test_vitals: 'report_phase' of < %s >  =>> \n \n", tc_name)
                   ,$sformatf("** Note: *******************************************************************************************\n")
                   ,$sformatf("** Note: TESTBENCH: Running TESTCASE  -->  %s  <-- with SEED = %0d \n", tc_name, $get_initial_random_seed)
                   ,$sformatf("** Note: *******************************************************************************************\n")}
                   , UVM_NONE)
   endfunction

   function void configure_axi_env();
      axi_env_cfg              = axi_env_config::type_id::create("axi_env_cfg", this);
      axi_env_cfg.sys_cfg      = sys_config::type_id::create("axi_env_cfg.sys_cfg", this);
      axi_env_cfg.axim_agt_cfg = axi_agent_config#(ID_WIDTH, ADDR_WIDTH, BYTE_WIDTH, USER_WIDTH)::type_id::create("axi_env_cfg.axim_agt_cfg", this);
      axi_env_cfg.axis_agt_cfg = axi_agent_config#(ID_WIDTH, ADDR_WIDTH, BYTE_WIDTH, USER_WIDTH)::type_id::create("axi_env_cfg.axis_agt_cfg", this);

      axi_env_cfg.sys_cfg.clk_freq       = 250;
      axi_env_cfg.sys_cfg.clk_duty_cycle = 50;
      axi_env_cfg.sys_cfg.rst_assert     = 20;
      axi_env_cfg.sys_cfg.post_rst       = 20;

      axi_env_cfg.axim_agt_cfg.active    = UVM_ACTIVE;
      axi_env_cfg.axim_agt_cfg.master    = 1;

      axi_env_cfg.axis_agt_cfg.active    = UVM_ACTIVE;
      axi_env_cfg.axis_agt_cfg.master    = 0;

      assert (uvm_config_db #(virtual sys_if)::get(this, "", "sys_vi", axi_env_cfg.sys_cfg.sys_vi)) else
         `uvm_error(tID, "Failed to find sys_vi")
      assert (uvm_config_db #(virtual axi_if)::get(this, "", "axi_vi", axi_env_cfg.axim_agt_cfg.axi_vi)) else
         `uvm_error(tID, "Failed to find axi_vi")
      assert (uvm_config_db #(virtual axi_if)::get(this, "", "axi_vi", axi_env_cfg.axis_agt_cfg.axi_vi)) else
         `uvm_error(tID, "Failed to find axi_vi")

      axi_e.axi_env_cfg     = this.axi_env_cfg;
      tb_axi_sq.axi_env_cfg = this.axi_env_cfg;
   endfunction

   function void configure_axi_cntrl();
      axi_cntrl_cfg = axi_cntrl_config::type_id::create("axi_cntrl_cfg", this);

      axi_cntrl_cfg.min_wrap             = 1;
      axi_cntrl_cfg.max_wrap             = 1;

      axi_cntrl_cfg.min_addr             = 32'h00000000;
      axi_cntrl_cfg.max_addr             = 32'hFFFF0000;

      axi_cntrl_cfg.rand_data_percent    = 100;
      axi_cntrl_cfg.incr_data_percent    = 0;
      axi_cntrl_cfg.const_data_percent   = 0;

      axi_cntrl_cfg.sub_blk_size         = 64;

      axi_cntrl_cfg.blk_size64_percent   = 100;
      axi_cntrl_cfg.blk_size512_percent  = 0;
      axi_cntrl_cfg.blk_size1024_percent = 0;
      axi_cntrl_cfg.blk_size2048_percent = 0;
      axi_cntrl_cfg.blk_size4096_percent = 0;

      tb_axi_sq.axi_cntrl_cfg = this.axi_cntrl_cfg;
   endfunction

endclass
`endif
