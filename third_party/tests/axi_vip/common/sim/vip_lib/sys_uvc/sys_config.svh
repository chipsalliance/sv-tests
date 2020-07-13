// -*- coding: utf-8 -*-
//
// Copyright (C) 2020 The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
// SPDX-License-Identifier: ISC


`ifndef _SYS_CONFIG_SVH_
`define _SYS_CONFIG_SVH_

class sys_config extends uvm_object;
   `uvm_object_utils(sys_config)

   function new(string name = "sys_config");
      super.new(name);
   endfunction

   virtual sys_if   sys_vi;
   sys_sequencer    sqr;

   real             clk_freq;             //MHz
   bit [6:0]        clk_duty_cycle=50;    //percent of cycle clk is asserted

   int unsigned     rst_assert, post_rst; //ns

   bit [31:0]       pins;

   bit              has_functional_coverage;

   function string convert2string();
      string str1;
      str1 = {str1,"\n******************** sys_agent_config ********************\n"
                  ,$sformatf(" clk_freq                : %.2f MHz    \n", clk_freq)
                  ,$sformatf(" clk_duty_cycle          : %0d percent \n", clk_duty_cycle)
                  ,$sformatf(" rst_assert              : %0d clks    \n", rst_assert)
                  ,$sformatf(" post_rst                : %0d clks    \n", post_rst)
                  ,$sformatf(" pins                    : %h          \n", pins)
                  ,"******************** sys_agent_config ********************\n"};
      return(str1);
   endfunction

endclass
`endif
