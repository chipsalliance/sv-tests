// -*- coding: utf-8 -*-
//
// Copyright (C) 2020 The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
// SPDX-License-Identifier: ISC

`ifndef _AXI_TB_TOP_SV_
`define _AXI_TB_TOP_SV_

module axi_tb_top;
   import uvm_pkg::*;
   `include "uvm_macros.svh"

parameter BYTE_WIDTH=32;
parameter ADDR_WIDTH=64;
parameter ID_WIDTH=16;
parameter USER_WIDTH=4;

   sys_if     sys_vi();

   axi_if#(
           .ID_WIDTH   (ID_WIDTH),
           .ADDR_WIDTH (ADDR_WIDTH),
           .BYTE_WIDTH (BYTE_WIDTH),
           .USER_WIDTH (USER_WIDTH)
          )   axi_vi();

   initial begin
      uvm_config_db #(virtual sys_if)::set(null, "*", "sys_vi", sys_vi);

      uvm_config_db #(virtual axi_if#(
                                      .ID_WIDTH   (ID_WIDTH   ),
                                      .ADDR_WIDTH (ADDR_WIDTH),
                                      .BYTE_WIDTH (BYTE_WIDTH),
                                      .USER_WIDTH (USER_WIDTH)
                                     ))::set(null, "*", "axi_vi", axi_vi);
   end

   assign   axi_vi.clk           = sys_vi.clk;
   assign   axi_vi.rst_n         = sys_vi.rst_n;

   test_initiator   u_test_initiator();

endmodule
`endif
