// -*- coding: utf-8 -*-
//
// Copyright (C) 2020 The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
// SPDX-License-Identifier: ISC

package common_pkg;
   `include "uvm_macros.svh"
   import uvm_pkg::*;
   
   `define DISPLAY_PASS $display("%c[1;32m\nTest PASSED\n\n%c[0m",27,27);
   `define DISPLAY_FAIL $display("%c[1;31m\nTest FAILED\n\n%c[0m",27,27);

   `include "base_scoreboard.svh"
   `include "custom_report_server.svh"
endpackage
