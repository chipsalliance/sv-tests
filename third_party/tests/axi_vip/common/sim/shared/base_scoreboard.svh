// -*- coding: utf-8 -*-
//
// Copyright (C) 2020 The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
// SPDX-License-Identifier: ISC

//==================================================================================


`ifndef _BASE_SCOREBOARD_SVH_
`define _BASE_SCOREBOARD_SVH_

class base_scoreboard#(type trans_type = uvm_sequence_item, bit INORDER = 1) extends uvm_scoreboard;
   `uvm_component_utils(base_scoreboard#(trans_type))

   string tID;

   uvm_analysis_export #(trans_type)          exp_ae;
   uvm_analysis_export #(trans_type)          act_ae;
   local uvm_tlm_analysis_fifo #(trans_type)  exp_fifo, act_fifo;

   trans_type                                 exp_txn, exp_txn_clone, act_txn, exp_q[$];
   int                                        match_cnt, exp_cnt, act_cnt;
   bit                                        act, exp, match;

   function new(string name, uvm_component parent);
      super.new(name, parent);
     
      tID = get_name();
      tID = tID.toupper();
   endfunction

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      exp_fifo   = new("exp_fifo", this);
      act_fifo   = new("act_fifo", this);
      exp_ae     = new("exp_ae", this);
      act_ae     = new("act_ae", this);
   endfunction

   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
   
      exp_ae.connect(exp_fifo.analysis_export);
      act_ae.connect(act_fifo.analysis_export);
   endfunction

   task run_phase(uvm_phase phase);
      fork
         get_exp_txn();
         get_act_txn();
      join_none
   endtask

   task get_act_txn;
      forever begin
         act_fifo.get(act_txn);
         `uvm_info(tID, $sformatf("Received act_txn[%0d]: %s", act_cnt, act_txn.convert2string()), UVM_MEDIUM)
         act_cnt++;
         txn_compare();
      end
   endtask

   task get_exp_txn;
      forever begin
         exp_fifo.get(exp_txn);
         `uvm_info(tID, $sformatf("Received exp_txn[%0d]: %s", exp_cnt, exp_txn.convert2string()), UVM_MEDIUM)
         assert($cast(exp_txn_clone, exp_txn.clone()));
         exp_q.push_back(exp_txn_clone);
         exp_cnt++;
      end
   endtask

   task txn_compare();
      if (INORDER) begin
         if (act_txn.compare(exp_q[0])) begin
            `uvm_info(tID, $sformatf("MATCH[%0d]: act_txn -------|  =  |------- exp_txn[0]", match_cnt), UVM_MEDIUM)
            void'(exp_q.pop_front());
            match_cnt++;
         end
         else begin
            `uvm_error(tID, $sformatf({"MISMATCH[%0d]: act_txn -------|  !=  |------- exp_txn[0]\n",
                                       "act_txn: %s exp_txn[0]: %s"}, match_cnt, act_txn.convert2string(), exp_q[0].convert2string()))
             void'(exp_q.pop_front());
         end
      end
      else begin // out-of-order
         foreach(exp_q[i]) begin
            if (!match) begin
               if (act_txn.compare(exp_q[i])) begin
                  `uvm_info(tID, $sformatf("MATCH[%0d]: act_txn -------|  =  |-------exp_q[%0d]", match_cnt, i), UVM_MEDIUM)
                  `uvm_info(tID, $sformatf("act_txn: %s", act_txn.convert2string()), UVM_HIGH)
                  `uvm_info(tID, $sformatf("exp_q[%0d]: %s", i, exp_q[i].convert2string()), UVM_HIGH)
                  match = 1;
                  match_cnt++;
                  exp_q.delete(i);
               end
               else if (i == exp_q.size()-1)
                  `uvm_error(tID, $sformatf("NO MATCH for act_txn: %s", act_txn.convert2string()))
            end
            match = 0; //Reset for next act_txn
         end
      end
   endtask

   function void check_phase( uvm_phase phase );
      if ((act_cnt==0) && (exp_cnt==0))
         `uvm_error(tID, $sformatf("There were NO transactions sent to scoreboard"))
      else if ((match_cnt != act_cnt) || (match_cnt != exp_cnt))
         `uvm_error(tID, $sformatf("match_cnt = %0d, act_cnt = %0d, exp_cnt = %0d", match_cnt, act_cnt, exp_cnt))
   endfunction

endclass
`endif
