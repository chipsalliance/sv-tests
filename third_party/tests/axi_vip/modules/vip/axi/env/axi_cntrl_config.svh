// -*- coding: utf-8 -*-
//
// Copyright (C) 2020 The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
// SPDX-License-Identifier: ISC

`ifndef _AXI_CNTRL_CONFIG_SVH_
`define _AXI_CNTRL_CONFIG_SVH_

class axi_cntrl_config extends uvm_object;
   `uvm_object_utils(axi_cntrl_config)

   bit[6:0]            incr_data_percent, rand_data_percent, const_data_percent,
                       blk_size64_percent, blk_size512_percent, blk_size1024_percent, blk_size2048_percent, blk_size4096_percent;

   int unsigned        min_wrap, max_wrap, min_rd, max_rd, min_wr, max_wr,
                       min_addr, max_addr;
   rand int unsigned   num_wrap, num_rd, num_wr;

   rand bit [12:0]     blk_size;
   bit [12:0]          sub_blk_size;

   rand wr_data_type        wr_data;

   constraint num_wrap_c {
         num_wrap inside { [min_wrap : max_wrap] };
   }

   constraint num_wr_c {
      num_wr inside { [min_wr : max_wr] };
   }

   constraint num_rd_c {
      num_rd inside { [min_rd : max_rd] };
   }

   constraint blk_size_c {
      blk_size dist { 64:/ blk_size64_percent, 512 :/ blk_size512_percent, 1024 :/ blk_size1024_percent, 2048 :/ blk_size2048_percent, 4096 :/ blk_size4096_percent };
   }

   constraint wr_data_c {
      wr_data dist { INCR :/ incr_data_percent, RAND :/ rand_data_percent, CONST :/ const_data_percent };
   }

   function new(string name = "testbench_cntrl_config");
      super.new(name);
   endfunction

   function string convert2string();
      string str1;
      str1 = {str1,"\n******************** axi_cntrl_config ********************\n"
              ,$sformatf(" num_wr                           : %0d  \n", num_wr)
              ,$sformatf(" num_rd                           : %0d  \n", num_rd)
              ,$sformatf(" num_wrap                         : %0d  \n", num_wrap)
              ,$sformatf(" blk_size                         : %0d  \n", blk_size)
              ,$sformatf(" wr_data                          : %s   \n", wr_data.name())
              ,"------------------------------ TEST KNOBS -------------------------------\n"
              ,$sformatf(" min_wr                           : %0d  \n", min_wr)
              ,$sformatf(" max_wr                           : %0d  \n", max_wr)
              ,$sformatf(" min_rd                           : %0d  \n", min_rd)
              ,$sformatf(" max_rd                           : %0d  \n", max_rd)
              ,$sformatf(" min_wrap                         : %0d  \n", min_wrap)
              ,$sformatf(" max_wrap                         : %0d  \n", max_wrap)
              ,$sformatf(" min_addr                         : %0h  \n", min_addr)
              ,$sformatf(" max_addr                         : %0h  \n", max_addr)
              ,$sformatf(" blk_size64_percent               : %0d  \n", blk_size64_percent)
              ,$sformatf(" blk_size512_percent              : %0d  \n", blk_size512_percent)
              ,$sformatf(" blk_size1024_percent             : %0d  \n", blk_size1024_percent)
              ,$sformatf(" blk_size2048_percent             : %0d  \n", blk_size2048_percent)
              ,$sformatf(" blk_size4096_percent             : %0d  \n", blk_size4096_percent)
              ,$sformatf(" incr_data_percent                : %0d  \n", incr_data_percent)
              ,$sformatf(" rand_data_percent                : %0d  \n", rand_data_percent)
              ,$sformatf(" const_data_percent               : %0d  \n", const_data_percent)
              ,"******************** testbench_cntrl_config ********************\n"};
      return(str1);
   endfunction

endclass
`endif
