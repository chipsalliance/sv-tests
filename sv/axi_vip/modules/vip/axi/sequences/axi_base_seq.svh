// -*- coding: utf-8 -*-
//
// Copyright (C) 2020 The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
// SPDX-License-Identifier: ISC

`ifndef _AXI_BASE_SEQ_SVH_
`define _AXI_BASE_SEQ_SVH_

class axi_base_seq extends uvm_sequence#(uvm_sequence_item, uvm_sequence_item);
   `uvm_object_utils(axi_base_seq)

   string             tID;

   axi_trans          axi_txn, axi_txn_clone;
   axi_trans          axi_txn_q[$];

   axi_cntrl_config   axi_cntrl_cfg;

   bit [ADDR_WIDTH-1:0]   next_addr, next_data, tmp_addr, flip_addr;
   bit [7:0]              tot_len, next_len, num_ata_txn, ata_len, next_id, flip_data;
   bit [9:0]              flipped_bit_q[$];
   rand bit [7:0]         txn_len;
   rand bit [3:0]         bch_num_errors;
   rand bit [9:0]         flipped_bit;

   function new(string name = "axi_base_seq");
      super.new(name);

      tID = get_name();
      tID = tID.toupper();
   endfunction

   task body;
   endtask

endclass
`endif
