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
                  parameter BYTE_WIDTH = 32
                 );

   //Misc
   logic                         clk;
   logic                         rst_n;

   //Write Address Channel
   logic [ID_WIDTH-1:0]          awid;
   logic [ADDR_WIDTH-1:0]        awaddr;
   logic [7:0]                   awlen;
   logic [2:0]                   awsize;
   logic [1:0]                   awburst;
   logic [3:0]                   awcache;
   logic [2:0]                   awprot;
   logic [3:0]                   awqos;
   logic [3:0]                   awregion;
   logic                         awvalid;
   logic                         awready;

   //Write Data Channel
   logic [BYTE_WIDTH-1:0][7:0]   wdata;
   logic [BYTE_WIDTH-1:0]        wstrb;
   logic                         wlast;
   logic                         wvalid;
   logic                         wready;

   //Write Resp Channel
   logic [ID_WIDTH-1:0]          bid;
   logic [1:0]                   bresp;
   logic                         bvalid;
   logic                         bready;

   //Read Address Channel
   logic [ID_WIDTH-1:0]          arid;
   logic [ADDR_WIDTH-1:0]        araddr;
   logic [7:0]                   arlen;
   logic [2:0]                   arsize;
   logic [1:0]                   arburst;
   logic [3:0]                   arcache;
   logic [2:0]                   arprot;
   logic [3:0]                   arqos;
   logic [3:0]                   arregion;
   logic                         arvalid;
   logic                         arready;

   //Read Data Channel
   logic [ID_WIDTH-1:0]          rid;
   logic [BYTE_WIDTH-1:0][7:0]   rdata;
   logic [1:0]                   rresp;
   logic                         rlast;
   logic                         rvalid;
   logic                         rready;

   modport master(
      output   awid, awaddr, awlen, awsize, awburst, awcache, awprot, awqos, awregion, awuser, awvalid,
      input    awready,

      output   wdata, wstrb, wlast, wuser, wvalid,
      input    wready,

      input    bid, bresp, buser, bvalid,
      output   bready,

      output   arid, araddr, arlen, arsize, arburst, arcache, arprot, arqos, arregion, aruser, arvalid,
      input    arready,

      input    rid, rdata, rresp, rlast, ruser, rvalid,
      output   rready
   );

   modport slave(
      input    awid, awaddr, awlen, awsize, awburst, awcache, awprot, awqos, awregion, awuser, awvalid,
      output   awready,

      input    wdata, wstrb, wlast, wuser, wvalid,
      output   wready,

      output   bid, bresp, buser, bvalid,
      input    bready,

      input    arid, araddr, arlen, arsize, arburst, arcache, arprot, arqos, arregion, aruser, arvalid,
      output   arready,

      output   rid, rdata, rresp, rlast, ruser, rvalid,
      input    rready
   );
endinterface
