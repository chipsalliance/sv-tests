// -*- coding: utf-8 -*-
//
// Copyright (C) 2020 The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
// SPDX-License-Identifier: ISC

`ifndef _AXI_DRIVER_SVH_
`define _AXI_DRIVER_SVH_

class axi_driver#(parameter ID_WIDTH   = 16,
                  parameter ADDR_WIDTH = 64,
                  parameter BYTE_WIDTH = 32,
                  parameter USER_WIDTH = 4
                 ) extends uvm_driver#(axi_trans, axi_trans);
   `uvm_component_param_utils(axi_driver#(ID_WIDTH, ADDR_WIDTH, BYTE_WIDTH, USER_WIDTH))

   string                              tID;
   axi_trans                           req, rsp, req_clone, rsp_clone;
   uvm_analysis_port#(axi_trans)       ap;
   uvm_tlm_analysis_fifo#(axi_trans)   analysis_fifo; //From monitor, for slave responses
   rand int unsigned                   aw_ready_delay, w_ready_delay, b_ready_delay,
                                       ar_ready_delay, r_ready_delay;

   axi_agent_config #(
                      .ID_WIDTH    (ID_WIDTH   ),
                      .ADDR_WIDTH  (ADDR_WIDTH ),
                      .BYTE_WIDTH  (BYTE_WIDTH ),
                      .USER_WIDTH  (USER_WIDTH )
                     )   cfg;

   function new(string name = "axi_driver", uvm_component parent = null);
      super.new(name, parent);

      tID = get_full_name();
      tID = tID.toupper();
   endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      ap            = new("ap", this);
      analysis_fifo = new("analysis_fifo",this);
   endfunction

   virtual task run_phase(uvm_phase phase);
      init_axi();

      fork
         aw_rdy();
         w_rdy();
         b_rdy();
         ar_rdy();
         r_rdy();
         get_item();
         get_rsp_item();
      join_none
   endtask

   task init_axi();
      if (cfg.master) begin
         cfg.axi_vi.cb.awid     <= '0;
         cfg.axi_vi.cb.awaddr   <= '0;
         cfg.axi_vi.cb.awlen    <= '0;
         cfg.axi_vi.cb.awsize   <= '0;
         cfg.axi_vi.cb.awburst  <= '0;
         cfg.axi_vi.cb.awcache  <= '0;
         cfg.axi_vi.cb.awprot   <= '0;
         cfg.axi_vi.cb.awqos    <= '0;
         cfg.axi_vi.cb.awregion <= '0;
         cfg.axi_vi.cb.awuser   <= '0;
         cfg.axi_vi.cb.awvalid  <= '0;

         cfg.axi_vi.cb.wdata    <= '0;
         cfg.axi_vi.cb.wstrb    <= '0;
         cfg.axi_vi.cb.wlast    <= '0;
         cfg.axi_vi.cb.wuser    <= '0;
         cfg.axi_vi.cb.wvalid   <= '0;

         cfg.axi_vi.cb.bready   <= '0;

         cfg.axi_vi.cb.arid     <= '0;
         cfg.axi_vi.cb.araddr   <= '0;
         cfg.axi_vi.cb.arlen    <= '0;
         cfg.axi_vi.cb.arsize   <= '0;
         cfg.axi_vi.cb.arburst  <= '0;
         cfg.axi_vi.cb.arcache  <= '0;
         cfg.axi_vi.cb.arprot   <= '0;
         cfg.axi_vi.cb.arqos    <= '0;
         cfg.axi_vi.cb.arregion <= '0;
         cfg.axi_vi.cb.aruser   <= '0;
         cfg.axi_vi.cb.arvalid  <= '0;

         cfg.axi_vi.cb.rready   <= '0;
      end
      else begin
         cfg.axi_vi.cb.bid      <= '0;
         cfg.axi_vi.cb.bresp    <= '0;
         cfg.axi_vi.cb.buser    <= '0;
         cfg.axi_vi.cb.bvalid   <= '0;

         cfg.axi_vi.cb.rid      <= '0;
         cfg.axi_vi.cb.rresp    <= '0;
         cfg.axi_vi.cb.rdata    <= '0;
         cfg.axi_vi.cb.rlast    <= '0;
         cfg.axi_vi.cb.ruser    <= '0;
         cfg.axi_vi.cb.rvalid   <= '0;

         cfg.axi_vi.cb.awready  <= '0;
         cfg.axi_vi.cb.wready   <= '0;
         cfg.axi_vi.cb.arready  <= '0;
      end
   endtask

   task aw_rdy();
      bit   awready_int;

      if (!cfg.master) begin
         if (cfg.aw_ready_delays) begin
            forever begin
               assert (this.randomize(aw_ready_delay) with {aw_ready_delay inside { [cfg.min_aw_ready_delay : cfg.max_aw_ready_delay] };}) else
                  `uvm_fatal(tID, "aw_ready_delay Failed to Randomize")
               for (int i=0; i<aw_ready_delay; i++)
                  @(negedge cfg.axi_vi.clk iff cfg.axi_vi.rst_n);
               awready_int = !awready_int;
               cfg.axi_vi.cb.awready <= awready_int;
            end
         end
         else
            cfg.axi_vi.cb.awready <= 1'b1;
      end
   endtask

   task w_rdy();
      bit   wready_int;

      if (!cfg.master) begin
         if (cfg.w_ready_delays) begin
            forever begin
               assert (this.randomize(w_ready_delay) with {w_ready_delay inside { [cfg.min_w_ready_delay : cfg.max_w_ready_delay] };}) else
                  `uvm_fatal(tID, "w_ready_delay Failed to Randomize")
               for (int i=0; i<w_ready_delay; i++)
                  @(negedge cfg.axi_vi.clk iff cfg.axi_vi.rst_n);
               wready_int = !wready_int;
               cfg.axi_vi.cb.wready <= wready_int;
            end
         end
         else
            cfg.axi_vi.cb.wready <= 1'b1;
      end
   endtask

   task ar_rdy();
      bit   arready_int;

      if (!cfg.master) begin
         if (cfg.ar_ready_delays) begin
            forever begin
               assert (this.randomize(ar_ready_delay) with {ar_ready_delay inside { [cfg.min_ar_ready_delay : cfg.max_ar_ready_delay] };}) else
                  `uvm_fatal(tID, "ar_ready_delay Failed to Randomize")
               for (int i=0; i<ar_ready_delay; i++)
                  @(negedge cfg.axi_vi.clk iff cfg.axi_vi.rst_n);
               arready_int = !arready_int;
               cfg.axi_vi.cb.arready <= arready_int;
            end
         end
         else
            cfg.axi_vi.cb.arready <= 1'b1;
      end
   endtask

   task b_rdy();
      bit   bready_int;

      if (cfg.master) begin
         if (cfg.b_ready_delays) begin
            forever begin
               assert (this.randomize(b_ready_delay) with {b_ready_delay inside { [cfg.min_b_ready_delay : cfg.max_b_ready_delay] };}) else
                  `uvm_fatal(tID, "b_ready_delay Failed to Randomize")
               for (int i=0; i<b_ready_delay; i++)
                  @(negedge cfg.axi_vi.clk iff cfg.axi_vi.rst_n);
               bready_int = !bready_int;
               cfg.axi_vi.cb.bready <= bready_int;
            end
         end
         else
            cfg.axi_vi.cb.bready <= 1'b1;
      end
   endtask

   task r_rdy();
      bit   rready_int;

      if (cfg.master) begin
         if (cfg.r_ready_delays) begin
            forever begin
               assert (this.randomize(r_ready_delay) with {r_ready_delay inside { [cfg.min_r_ready_delay : cfg.max_r_ready_delay] };}) else
                  `uvm_fatal(tID, "r_ready_delay Failed to Randomize")
               for (int i=0; i<r_ready_delay; i++)
                  @(negedge cfg.axi_vi.clk iff cfg.axi_vi.rst_n);
               rready_int = !rready_int;
               cfg.axi_vi.cb.rready <= rready_int;
            end
         end
         else
            cfg.axi_vi.cb.rready <= 1'b1;
      end
   endtask

   task get_item();
      forever begin
         seq_item_port.get_next_item(req);
         case (req.ttype)
            AXI_WR: begin
                       drv_aw();
                       drv_w();
                    end
            AXI_RD: drv_ar();
         endcase
         seq_item_port.item_done();
      end
   endtask

   task get_rsp_item();
      forever begin
         analysis_fifo.get(rsp);
         case (rsp.ttype)
            AXI_WR: drv_b();
            AXI_RD: drv_r();
         endcase
      end
   endtask

   task drv_aw();
      do begin
         cfg.axi_vi.cb.awid     <= req.id;
         cfg.axi_vi.cb.awaddr   <= req.addr;
         cfg.axi_vi.cb.awlen    <= req.len;
         cfg.axi_vi.cb.awsize   <= req.size;
         cfg.axi_vi.cb.awburst  <= req.burst;
         cfg.axi_vi.cb.awcache  <= req.cache;
         cfg.axi_vi.cb.awprot   <= req.prot;
         cfg.axi_vi.cb.awqos    <= req.qos;
         cfg.axi_vi.cb.awregion <= req.region;
         cfg.axi_vi.cb.awuser   <= req.awuser;
         cfg.axi_vi.cb.awvalid  <= 1'b1;
         @(negedge cfg.axi_vi.clk);
      end
      while (!cfg.axi_vi.cb.awready);
      cfg.axi_vi.cb.awvalid <= 1'b0;
   endtask

   task drv_w();
      for (int i=0; i<req.len+1; i++) begin
         for (int j=0; j<req.get_width(req.size); j++) begin
            cfg.axi_vi.cb.wdata[req.get_width(req.size)-1-j] <= req.data[(i*req.get_width(req.size))+j];
            cfg.axi_vi.cb.wstrb[req.get_width(req.size)-1-j] <= req.wstrb[(i*req.get_width(req.size))+j];
         end
         cfg.axi_vi.cb.wvalid <= 1'b1;
         if (i==req.len)
            cfg.axi_vi.cb.wlast <= 1'b1;
         do @(negedge cfg.axi_vi.clk);
         while (!cfg.axi_vi.cb.wready);
      end
      cfg.axi_vi.cb.wvalid <= 1'b0;
      cfg.axi_vi.cb.wlast  <= 1'b0;
   endtask

   task drv_b();
      `uvm_info(tID, $sformatf("Drive b, rsp: %s", rsp.convert2string()), UVM_MEDIUM)
      do begin
         cfg.axi_vi.cb.bid    <= rsp.id;
         cfg.axi_vi.cb.bresp  <= 2'b00; // TODO: Inject errors
         cfg.axi_vi.cb.bvalid <= 1'b1;
         @(negedge cfg.axi_vi.clk);
      end
      while (!cfg.axi_vi.cb.bready);
      cfg.axi_vi.cb.bvalid <= 1'b0;
   endtask

   task drv_ar();
      do begin
         cfg.axi_vi.cb.arid     <= req.id;
         cfg.axi_vi.cb.araddr   <= req.addr;
         cfg.axi_vi.cb.arlen    <= req.len;
         cfg.axi_vi.cb.arsize   <= req.size;
         cfg.axi_vi.cb.arburst  <= req.burst;
         cfg.axi_vi.cb.arcache  <= req.cache;
         cfg.axi_vi.cb.arprot   <= req.prot;
         cfg.axi_vi.cb.arqos    <= req.qos;
         cfg.axi_vi.cb.arregion <= req.region;
         cfg.axi_vi.cb.arvalid  <= 1'b1;
         @(negedge cfg.axi_vi.clk);
      end
      while (!cfg.axi_vi.cb.arready);
      cfg.axi_vi.cb.arvalid  <= 1'b0;
      @(negedge cfg.axi_vi.clk);
   endtask

   task drv_r();
      cfg.axi_vi.cb.rid    <= rsp.id;
      cfg.axi_vi.cb.rvalid <= 1'b1;
      for (int i=0; i<rsp.len+1; i++) begin
            for (int j=rsp.get_width(rsp.size)-1; j>=0; j--) begin
               cfg.axi_vi.cb.rdata[rsp.get_width(rsp.size)-1-j] <= rsp.data[i*rsp.get_width(rsp.size)+j];
               cfg.axi_vi.cb.rresp                              <= rsp.rresp[i];
            end
            if (i == rsp.len)
               cfg.axi_vi.cb.rlast <= 1'b1;
         @(negedge cfg.axi_vi.clk);
      end
      cfg.axi_vi.cb.rid    <=  'b0;
      cfg.axi_vi.cb.rdata  <=  'b0;
      cfg.axi_vi.cb.rlast  <= 1'b0;
      cfg.axi_vi.cb.rvalid <= 1'b0;
      @(negedge cfg.axi_vi.clk);
   endtask

endclass
`endif
