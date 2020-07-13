// -*- coding: utf-8 -*-
//
// Copyright (C) 2020 The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
// SPDX-License-Identifier: ISC

`ifndef _SYS_DRIVER_SVH_
`define _SYS_DRIVER_SVH_

class sys_driver extends uvm_driver #(sys_trans, sys_trans);
   `uvm_component_utils(sys_driver)

   sys_config   cfg;

   function new(string name = "sys_driver", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
   endfunction

   task run_phase(uvm_phase phase);
      cfg.sys_vi.pins = cfg.pins;
      get_and_drive();
   endtask

   task get_and_drive();
      forever begin
         sys_trans   req_item, rsp_item;

         seq_item_port.get_next_item(req_item);

         if (req_item.start_clk)
            start_clk;
         if (req_item.assert_rst)
            assert_rst;
         seq_item_port.item_done();
      end
   endtask

   task start_clk();
      real   clk_period;

      clk_period = (1/cfg.clk_freq)*1000000; //ps

      fork
         forever begin
            cfg.sys_vi.clk = 1'b0;
            #(clk_period*(100-cfg.clk_duty_cycle)/100.0);
            cfg.sys_vi.clk = 1'b1;
            #(clk_period*cfg.clk_duty_cycle/100.0);
         end
      join_none
   endtask

   task assert_rst();
     cfg.sys_vi.rst_n = 1'b0;
     for (int i=0; i<cfg.rst_assert; i++)
       #1ns;
     cfg.sys_vi.rst_n = 1'b1;
     for (int i=0; i<cfg.post_rst; i++)
       #1ns;
   endtask

endclass
`endif
