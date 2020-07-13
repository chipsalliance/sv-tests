// -*- coding: utf-8 -*-
//
// Copyright (C) 2020 The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
// SPDX-License-Identifier: ISC

`ifndef _AXI_SEQUENCER_SVH_
`define _AXI_SEQUENCER_SVH_

class axi_sequencer extends uvm_sequencer#(axi_trans, axi_trans);
   `uvm_component_utils(axi_sequencer)

   function new(string name = "axi_sequencer",uvm_component parent = null);
      super.new(name, parent);
   endfunction

endclass
`endif
