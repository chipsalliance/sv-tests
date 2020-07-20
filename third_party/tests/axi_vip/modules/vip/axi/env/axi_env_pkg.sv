// -*- coding: utf-8 -*-
//
// Copyright (C) 2020 The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
// SPDX-License-Identifier: ISC

`ifndef _AXI_ENV_PKG_SV_
`define _AXI_ENV_PKG_SV_

package axi_env_pkg;
   import uvm_pkg::*;
   `include "uvm_macros.svh"

   import common_pkg::*;
   import sys_uvc_pkg::*;
   import axi_agent_pkg::*;

   parameter BYTE_WIDTH=32;
   parameter ADDR_WIDTH=64;
   parameter ID_WIDTH=16;
   parameter USER_WIDTH=4;

   `include "axi_cntrl_config.svh"
   `include "axi_env_config.svh"
   `include "axi_wrap_predictor.svh"
   `include "axi_env.svh"

endpackage
`endif
