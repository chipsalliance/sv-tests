// -*- coding: utf-8 -*-
//
// Copyright (C) 2020 The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
// SPDX-License-Identifier: ISC

`ifndef _AXI_WRAP_SEQ_SVH_
`define _AXI_WRAP_SEQ_SVH_

class axi_wrap_seq extends axi_base_seq;
   `uvm_object_utils(axi_wrap_seq)

   bit [ID_WIDTH-1:0]          used_id_q[$];
   bit [ADDR_WIDTH-1:0]        used_addr_q[$];

   rand bit [ADDR_WIDTH-1:0]   next_addr;
   bit [ADDR_WIDTH-1:0]        min_addr, max_addr;
   int unsigned                next_data;

   constraint next_addr_c {
      next_addr inside { [axi_cntrl_cfg.min_addr : axi_cntrl_cfg.max_addr] };
      next_addr % 17'h10000 == 0;
   }

   function new(string name = "axi_wrap_seq");
      super.new(name);
   endfunction

   task body();
      super.body();

      for (int i=0; i<axi_cntrl_cfg.num_wrap; i++) begin
     do void'(randomize(next_addr));
     while (next_addr inside {used_addr_q});
     used_addr_q.push_back(next_addr);
         next_data = 0;
         axi_txn = new();
         axi_txn.set_size(BYTE_WIDTH);
         for (int j=0; j<axi_cntrl_cfg.blk_size/axi_cntrl_cfg.sub_blk_size; j++) begin
            axi_txn.data_val = next_data;
        do begin
               assert (axi_txn.randomize() with {ttype   == AXI_WR;
                                                 wr_data == axi_cntrl_cfg.wr_data;
                                                 len     == 1;
                                                })
               else
                  `uvm_error(tID, "axi_txn Failed to Randomize")
               axi_txn.addr = next_addr;
               `uvm_info(tID, $sformatf("wr_txn: %s", axi_txn.convert2string()), UVM_MEDIUM)
        end
        while (axi_txn.id inside {used_id_q});
        used_id_q.push_back(axi_txn.id);
            assert($cast(axi_txn_clone, axi_txn.clone()));
            axi_txn_q.push_back(axi_txn_clone);
            next_addr += BYTE_WIDTH*(axi_txn.len+1);
            if (axi_cntrl_cfg.wr_data == INCR)
               next_data += axi_txn.len+1;//SEN: get_width?
         end
      end
      `uvm_info(tID, $sformatf("Number of wrap commands: %0d, start_addresses = %p\n", axi_cntrl_cfg.num_wrap, used_addr_q), UVM_MEDIUM)

      foreach (axi_txn_q[i]) begin
         `uvm_info(tID, $sformatf("AXI wr_txn[%0d]: %s", i, axi_txn_q[i].convert2string()), UVM_MEDIUM)
         assert($cast(axi_txn_clone, axi_txn_q[i].clone()));
         start_item(axi_txn_clone);
         finish_item(axi_txn_clone);
      end

      #20ns;

      foreach (axi_txn_q[i]) begin
         axi_txn_q[i].ttype = AXI_RD;
         assert($cast(axi_txn_clone, axi_txn_q[i].clone()));
         start_item(axi_txn_clone);
         finish_item(axi_txn_clone);
      end
   endtask

endclass
`endif
