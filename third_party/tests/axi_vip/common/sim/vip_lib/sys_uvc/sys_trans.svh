// -*- coding: utf-8 -*-
//
// Copyright (C) 2020 The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
// SPDX-License-Identifier: ISC

`ifndef _SYS_TRANS_SVH_
`define _SYS_TRANS_SVH_

class sys_trans extends uvm_sequence_item;
   `uvm_object_utils(sys_trans)

   bit   start_clk;
   bit   assert_rst;

   function new(string name = "sys_trans");
      super.new(name);
   endfunction

   virtual function void do_copy(uvm_object rhs);
      sys_trans   rhs_;
      $cast(rhs_, rhs);
      super.do_copy(rhs);

      this.start_clk  = rhs_.start_clk;
      this.assert_rst = rhs_.assert_rst;
   endfunction

endclass
`endif
