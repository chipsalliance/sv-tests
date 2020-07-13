// -*- coding: utf-8 -*-
//
// Copyright (C) 2020 The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
// SPDX-License-Identifier: ISC

`ifndef _SYS_SEQUENCER_SVH_
`define _SYS_SEQUENCER_SVH_

class sys_sequencer extends uvm_sequencer #(sys_trans, sys_trans);
   `uvm_component_utils(sys_sequencer)

   function new(string name = "sys_sequencer",uvm_component parent = null);
      super.new(name, parent);
   endfunction

endclass
`endif
