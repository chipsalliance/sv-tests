// -*- coding: utf-8 -*-
//
// Copyright (C) 2020 The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
// SPDX-License-Identifier: ISC

`ifndef _AXI_MONITOR_SVH_
`define _AXI_MONITOR_SVH_

class axi_monitor#(
                   parameter ID_WIDTH   = 16,
                   parameter ADDR_WIDTH = 64,
                   parameter BYTE_WIDTH = 32,
                   parameter USER_WIDTH = 4
                   ) extends uvm_monitor;
   `uvm_component_param_utils(axi_monitor#(ID_WIDTH, ADDR_WIDTH, BYTE_WIDTH, USER_WIDTH))

   string              tID;

   axi_agent_config#(
                     .ID_WIDTH   (ID_WIDTH  ),
                     .ADDR_WIDTH (ADDR_WIDTH),
                     .BYTE_WIDTH (BYTE_WIDTH),
                     .USER_WIDTH (USER_WIDTH)
                    )   cfg;

   axis_memory     #(
                     .BYTE_WIDTH(BYTE_WIDTH)
                    )   mem;

   axi_trans   trans_aw, trans_aw_clone, trans_w, trans_w_clone, trans_wr, trans_wr_clone, trans_wr_rsp, trans_wr_rsp_clone,
               trans_ar, trans_ar_clone, trans_r, trans_r_clone, trans_rd, trans_rd_clone,
               trans_aw_q[$], trans_w_q[$], trans_b_q[$], trans_wr_rsp_q[$], trans_wr_q[$], trans_rd_q[$];

   uvm_analysis_port#(axi_trans)   ap, rsp_ap;

   function new(string name = "axi_monitor", uvm_component parent = null);
      super.new(name, parent);

      tID = get_full_name();
      tID = tID.toupper();
   endfunction

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      ap     = new("ap", this);
      rsp_ap = new("rsp_ap", this);
   endfunction // build_phase

   task run_phase(uvm_phase phase);
      super.run_phase(phase);
      fork
         collect_aw();
         collect_w();
         collect_b();
         get_wr();
         collect_ar();
         collect_r();

      join_none
   endtask

   task collect_aw();
      forever begin
         @(posedge cfg.axi_vi.cb.awvalid && cfg.axi_vi.cb.awready);
         trans_aw = new();
         trans_aw.ttype  = AXI_AW;
         trans_aw.id     = cfg.axi_vi.cb.awid;
         trans_aw.addr   = cfg.axi_vi.cb.awaddr;
         trans_aw.len    = cfg.axi_vi.cb.awlen;
         trans_aw.size   = cfg.axi_vi.cb.awsize;
         trans_aw.burst  = cfg.axi_vi.cb.awburst;
         trans_aw.cache  = cfg.axi_vi.cb.awcache;
         trans_aw.prot   = cfg.axi_vi.cb.awprot;
         trans_aw.qos    = cfg.axi_vi.cb.awqos;
         trans_aw.region = cfg.axi_vi.cb.awregion;
         $cast(trans_aw_clone, trans_aw.clone());
         trans_aw_q.push_back(trans_aw_clone);
      end
   endtask

   task collect_w();
      bit   last, valid;

      forever begin
         @(posedge cfg.axi_vi.cb.wvalid && cfg.axi_vi.cb.wready);
         valid = 1;
         do begin
            @(negedge cfg.axi_vi.clk);
            if (cfg.axi_vi.cb.wvalid) begin
               trans_w = new();
               trans_w.ttype = AXI_W;
               trans_w.set_size(BYTE_WIDTH); //For convert2string()
               do begin
                  for (int i=BYTE_WIDTH-1; i>=0; i--) begin
                     trans_w.data.push_back(cfg.axi_vi.cb.wdata[i]);
                     trans_w.wstrb.push_back(cfg.axi_vi.cb.wstrb[i]);
                  end
                  if (cfg.axi_vi.cb.wlast) begin
                     last = 1;
                     $cast(trans_w_clone, trans_w.clone());
                     trans_w_q.push_back(trans_w_clone);
                  end
                  else
                     @(negedge cfg.axi_vi.clk);
               end
               while (!last);
               last = 0;
            end
            else
               valid = 0;
         end
         while (valid);
      end
   endtask

   task get_wr();
      forever begin
         wait (trans_w_q.size() && trans_aw_q.size());
         $cast(trans_wr, trans_aw_q[0].clone());
         trans_wr.ttype = AXI_WR;
         trans_wr.data  = trans_w_q[0].data;
         trans_wr.wstrb = trans_w_q[0].wstrb;
         $cast(trans_wr_clone, trans_wr.clone());
         trans_wr_q.push_back(trans_wr_clone);
         if (!cfg.master)
            rsp_ap.write(trans_wr_clone);
         void'(trans_w_q.pop_front());
         void'(trans_aw_q.pop_front());
         if (mem != null) begin
            mem.write(trans_wr); //Update slave memory
end
      end
   endtask

   task collect_b();
      bit   match;
      int   match_i;

      forever begin
         @(posedge cfg.axi_vi.cb.bvalid && cfg.axi_vi.cb.bready);
         `uvm_info(tID, $sformatf("Captured b, bid = %0h", cfg.axi_vi.cb.bid), UVM_MEDIUM)
         for (int i=0; i<trans_wr_q.size(); i++) begin
            if (cfg.axi_vi.cb.bid == trans_wr_q[i].id) begin
               match   = 1;
               match_i = i;
               if (cfg.axi_vi.cb.bresp == 0) begin
                  `uvm_info(tID, $sformatf("Sending wr: match = %0d, %s", match, trans_wr.convert2string()), UVM_MEDIUM)
                   $cast(trans_wr_clone, trans_wr_q[i].clone());
                   ap.write(trans_wr_clone);
               end
               else
                  `uvm_error(tID, $sformatf("trans_wr.bresp != 0, bid = %0h, bresp = %0b", cfg.axi_vi.cb.bid, cfg.axi_vi.cb.bresp))
            end
         end

         if (match) begin
            match = 0;
            trans_wr_q.delete(match_i);
         end
         else
            `uvm_error(tID, $sformatf("bid(%0h) does match any outstanding write transaction's id", cfg.axi_vi.cb.bid))
      end
   endtask

   task collect_ar();
      forever begin
         @(posedge cfg.axi_vi.cb.arvalid && cfg.axi_vi.cb.arready);
         trans_ar = new();
         trans_ar.ttype  = AXI_RD;
         trans_ar.id     = cfg.axi_vi.cb.arid;
         trans_ar.addr   = cfg.axi_vi.cb.araddr;
         trans_ar.len    = cfg.axi_vi.cb.arlen;
         trans_ar.size   = cfg.axi_vi.cb.arsize;
         trans_ar.burst  = cfg.axi_vi.cb.arburst;
         trans_ar.cache  = cfg.axi_vi.cb.arcache;
         trans_ar.prot   = cfg.axi_vi.cb.arprot;
         trans_ar.qos    = cfg.axi_vi.cb.arqos;
         trans_ar.region = cfg.axi_vi.cb.arregion;
         `uvm_info(tID, $sformatf("Captured ar, trans_ar = %s", trans_ar.convert2string()), UVM_MEDIUM)
         $cast(trans_ar_clone, trans_ar.clone());
         trans_rd_q.push_back(trans_ar_clone);
         if (!cfg.master) begin
            if (mem != null)
            mem.read(trans_ar);
            $cast(trans_ar_clone, trans_ar.clone());
            // TODO: add else for random data if no mem
            rsp_ap.write(trans_ar_clone);
         end
      end
   endtask

   task collect_r();
      bit   match, last;
      int   match_i;

      forever begin
         @(posedge cfg.axi_vi.cb.rvalid && cfg.axi_vi.cb.rready);
         for (int i=0; i<trans_rd_q.size(); i++) begin
            if (cfg.axi_vi.cb.rid == trans_rd_q[i].id) begin
               match   = 1;
               match_i = i;
            end
         end

         if (match)
            $cast(trans_rd, trans_rd_q[match_i].clone());
         else
            `uvm_error(tID, $sformatf("rid(%0h) does match any outstanding read transaction's id", cfg.axi_vi.cb.rid))

         do begin
            @(negedge cfg.axi_vi.clk);
            for (int j=trans_rd.get_width(trans_rd.size)-1; j>=0; j--) begin
               trans_rd.data.push_back(cfg.axi_vi.cb.rdata[j]);
               trans_rd.rresp.push_back(cfg.axi_vi.cb.rresp);
            end
            if (cfg.axi_vi.cb.rlast)
               last = 1;
         end
         while (!last);
         last = 0;

         //Check rresp
         for (int j=0; j<=trans_rd.len; j++) begin
            if (trans_rd.rresp[j] != 0)
               `uvm_error(tID, $sformatf("trans_rd.rresp[%0d] != 0, trans_rd.id = %0h, rresp = %0b", j, trans_rd.id, trans_rd.rresp[j]))
         end

         $cast(trans_rd_clone, trans_rd.clone());
         ap.write(trans_rd_clone);

         match = 0;
         trans_rd_q.delete(match_i);
      end
   endtask

endclass
`endif
