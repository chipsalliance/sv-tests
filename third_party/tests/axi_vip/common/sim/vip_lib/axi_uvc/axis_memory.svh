// -*- coding: utf-8 -*-
//
// Copyright (C) 2020 The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
// SPDX-License-Identifier: ISC

`ifndef _AXIS_MEMORY_SVH_
`define _AXIS_MEMORY_SVH_

class axis_memory#(parameter BYTE_WIDTH = 1) extends uvm_object;
   `uvm_object_param_utils(axis_memory#(BYTE_WIDTH))

   string   tID;

   byte     memory[*];

   function new(string name = "axis_memory");
      super.new(name);

      tID = get_full_name();
      tID = tID.toupper();
   endfunction

   // Write memory given axi wr_txn
   function void write(axi_trans txn);
      int unsigned   addr;

      addr = txn.addr;
      for (int unsigned i=0; i<txn.data.size()/BYTE_WIDTH; i++) begin
         for (int unsigned j=0; j<BYTE_WIDTH; j++) begin
            if (txn.wstrb[i*txn.get_width(txn.size)+j]) begin
               memory[addr] = txn.data[i*txn.get_width(txn.size)+j];
               `uvm_info(tID, $sformatf("write: addr = %0h, data = %2h", addr, txn.data[i*txn.get_width(txn.size)+j]), UVM_DEBUG)
            end
            addr++;
         end
      end
     endfunction

   // Read memory given axi rd_txn
   function void read(ref axi_trans txn);
      int unsigned   addr;

      addr = txn.addr;
      for (int i=0; i<(txn.len+1)*txn.get_width(txn.size); i++) begin
         txn.data.push_back(memory[addr]);
         `uvm_info(tID, $sformatf("read: addr = %0h, data = %2h", addr, txn.data[i]), UVM_HIGH)
         addr++;
      end
   endfunction

   //Write single byte
   function void write_byte(int unsigned addr, bit[7:0] data);
      `uvm_info(tID, $sformatf("write_byte: addr = %0h, data = %2h", addr, data), UVM_MEDIUM)
      memory[addr] = data;
   endfunction

   // Read single byte
   function byte read_byte(int unsigned addr);
      `uvm_info(tID, $sformatf("read_byte: addr = %0h, data = %2h", addr, memory[addr]), UVM_MEDIUM)
      return memory[addr];
   endfunction

  //Flip bit
   function void flip_bit(int unsigned addr, bit[2:0] flip_bit);
      byte   pre_data, post_data;

      assert (memory.exists(addr)) else
         `uvm_error(tID, $sformatf("address %0h has not been written", addr))
      pre_data = read_byte(addr);
      post_data = pre_data;
      post_data[flip_bit] = !post_data[flip_bit];
      write_byte(addr, post_data);
      `uvm_info(tID, $sformatf("flip_bit: addr = %0h, bit = %0d, pre_data = %0h, post_data = %0h", addr, flip_bit, pre_data, post_data), UVM_NONE)
   endfunction

endclass
`endif
