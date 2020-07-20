// -*- coding: utf-8 -*-
//
// Copyright (C) 2020 The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
// SPDX-License-Identifier: ISC


interface axi_if#(
                  parameter ID_WIDTH   = 16,
                  parameter ADDR_WIDTH = 64,
                  parameter BYTE_WIDTH = 32,
                  parameter USER_WIDTH = 4
                 );

   //Misc
   wire                         clk;
   wire                         rst_n;

   //Write Address Channel
   wire [ID_WIDTH-1:0]          awid;
   wire [ADDR_WIDTH-1:0]        awaddr;
   wire [7:0]                   awlen;
   wire [2:0]                   awsize;
   wire [1:0]                   awburst;
   wire [3:0]                   awcache;
   wire [2:0]                   awprot;
   wire [3:0]                   awqos;
   wire [3:0]                   awregion;
   wire [USER_WIDTH-1:0]        awuser;
   wire                         awvalid;
   wire                         awready;

   //Write Data Channel
   wire [BYTE_WIDTH-1:0][7:0]   wdata;
   wire [BYTE_WIDTH-1:0]        wstrb;
   wire                         wlast;
   wire [USER_WIDTH-1:0]        wuser;
   wire                         wvalid;
   wire                         wready;

   //Write Resp Channel
   wire [ID_WIDTH-1:0]          bid;
   wire [1:0]                   bresp;
   wire [USER_WIDTH-1:0]        buser;
   wire                         bvalid;
   wire                         bready;

   //Read Address Channel
   wire [ID_WIDTH-1:0]          arid;
   wire [ADDR_WIDTH-1:0]        araddr;
   wire [7:0]                   arlen;
   wire [2:0]                   arsize;
   wire [1:0]                   arburst;
   wire [3:0]                   arcache;
   wire [2:0]                   arprot;
   wire [3:0]                   arqos;
   wire [3:0]                   arregion;
   wire [USER_WIDTH-1:0]        aruser;
   wire                         arvalid;
   wire                         arready;

   //Read Data Channel
   wire [ID_WIDTH-1:0]          rid;
   wire [BYTE_WIDTH-1:0][7:0]   rdata;
   wire [1:0]                   rresp;
   wire                         rlast;
   wire [USER_WIDTH-1:0]        ruser;
   wire                         rvalid;
   wire                         rready;

   clocking cb @(posedge clk iff rst_n);
      default input #1step;

      inout   awid, awaddr, awlen, awsize, awburst, awcache, awprot, awqos, awregion, awuser, awvalid;
      inout   awready;

      inout   wdata, wstrb, wlast, wuser, wvalid;
      inout   wready;

      inout   bid, bresp, buser, bvalid;
      inout   bready;

      inout   arid, araddr, arlen, arsize, arburst, arcache, arprot, arqos, arregion, aruser, arvalid; 
      inout   arready;

      inout   rid, rdata, rresp, rlast, ruser, rvalid;
      inout   rready;
   endclocking
endinterface
