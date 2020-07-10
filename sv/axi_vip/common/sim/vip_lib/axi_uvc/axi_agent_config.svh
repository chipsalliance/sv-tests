// -*- coding: utf-8 -*-
//
// Copyright (C) 2020 The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
// SPDX-License-Identifier: ISC

`ifndef _AXI_AGENT_CONFIG_SVH_
`define _AXI_AGENT_CONFIG_SVH_

class axi_agent_config#(
                        parameter ID_WIDTH   = 16,
                        parameter ADDR_WIDTH = 64,
                        parameter BYTE_WIDTH = 32,
                        parameter USER_WIDTH = 4
                       ) extends uvm_object;
   `uvm_object_param_utils(axi_agent_config#(ID_WIDTH, ADDR_WIDTH, BYTE_WIDTH, USER_WIDTH))

   virtual axi_if#(
                   .ID_WIDTH   ( ID_WIDTH   ),
                   .ADDR_WIDTH ( ADDR_WIDTH ),
                   .BYTE_WIDTH ( BYTE_WIDTH ),
                   .USER_WIDTH ( USER_WIDTH )
                  )   axi_vi;

   axi_sequencer             sqr;
   uvm_active_passive_enum   active = UVM_ACTIVE;
   bit                       has_functional_coverage;

   bit                       master;     //1:master, 0:slave
   bit [7:0]                 data_val;   //if constant write data (axi_trans.wr_data = CONST), value for all write data
                                         //if incrementing write data (axi_trans.wr_data = INCR), start value for write data

   bit                       user_data;

   bit [6:0]                 aw_ready_delays_percent, w_ready_delays_percent, b_ready_delays_percent,
                             ar_ready_delays_percent, r_ready_delays_percent;
   rand bit                  aw_ready_delays, w_ready_delays, b_ready_delays,
                             ar_ready_delays, r_ready_delays;
   int unsigned              min_aw_ready_delay, max_aw_ready_delay,
                             min_w_ready_delay, max_w_ready_delay,
                             min_b_ready_delay, max_b_ready_delay,
                             min_ar_ready_delay, max_ar_ready_delay,
                             min_r_ready_delay, max_r_ready_delay;

   constraint aw_ready_delays_c {
      if (!master)
         aw_ready_delays dist { 1 :/ aw_ready_delays_percent, 0 :/ (100 - aw_ready_delays_percent) };
      else
         aw_ready_delays == 0;
   }

   constraint w_ready_delays_c {
      if (!master)
         w_ready_delays dist { 1 :/ w_ready_delays_percent, 0 :/ (100 - w_ready_delays_percent) };
      else
         w_ready_delays == 0;
   }

   constraint b_ready_delays_c {
      if (master)
         b_ready_delays dist { 1 :/ b_ready_delays_percent, 0 :/ (100 - b_ready_delays_percent) };
      else
         b_ready_delays == 0;
   }

   constraint ar_ready_delays_c {
      if (!master)
         ar_ready_delays dist { 1 :/ ar_ready_delays_percent, 0 :/ (100 - ar_ready_delays_percent) };
      else
         ar_ready_delays == 0;
   }

   constraint r_ready_delays_c {
      if (master)
         r_ready_delays dist { 1 :/ r_ready_delays_percent, 0 :/ (100 - r_ready_delays_percent) };
      else
         r_ready_delays == 0;
   }

   function new(string name = "axi_agent_config");
      super.new(name);
   endfunction

   task automatic wait_clks(int unsigned num);
      for (int i=0; i<num; i++)
         @(posedge axi_vi.clk);
   endtask

   function string convert2string();
      string str1;

      if (!master)
         str1 = {str1,"\n******************** axi_agent_config ********************\n"
                     ,$sformatf(" master                  : %0d  \n", master)
                     ,$sformatf(" aw_ready_delays         : %0d  \n", aw_ready_delays)
                     ,$sformatf(" w_ready_delays          : %0d  \n", w_ready_delays)
                     ,$sformatf(" ar_ready_delays         : %0d  \n", ar_ready_delays)		 
                     ,"******************** axi_agent_config ********************\n"};
      else
         str1 = {str1,"\n******************** axi_agent_config ********************\n"
                     ,$sformatf(" master                  : %0d  \n", master)
                     ,$sformatf(" b_ready_delays          : %0d  \n", b_ready_delays)
                     ,$sformatf(" r_ready_delays          : %0d  \n", r_ready_delays)		 
                     ,"******************** axi_agent_config ********************\n"};
     return(str1);
  endfunction

endclass
`endif
