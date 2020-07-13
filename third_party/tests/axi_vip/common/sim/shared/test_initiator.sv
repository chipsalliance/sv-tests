// -*- coding: utf-8 -*-
//
// Copyright (C) 2020 The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
// SPDX-License-Identifier: ISC

module test_initiator;
   import uvm_pkg::*;
   `include "uvm_macros.svh"

   import test_pkg::*;

   initial begin
      run_test();
   end

   final begin
      uvm_report_server   svr;

      svr = uvm_report_server::get_server();

      if (svr.get_severity_count(UVM_FATAL) || svr.get_severity_count(UVM_ERROR))
         `DISPLAY_FAIL
      else
         `DISPLAY_PASS
   end
endmodule

