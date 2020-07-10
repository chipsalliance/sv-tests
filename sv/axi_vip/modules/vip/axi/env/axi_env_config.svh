// -*- coding: utf-8 -*-
//
// Copyright (C) 2020 The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
// SPDX-License-Identifier: ISC

`ifndef _AXI_ENV_CONFIG_SVH_
`define _AXI_ENV_CONFIG_SVH_

class axi_env_config extends uvm_object;
   `uvm_object_utils(axi_env_config)

   rand sys_config         sys_cfg;
   rand axi_agent_config   axim_agt_cfg, axis_agt_cfg;

   function new(string name = "axi_env_config");
      super.new(name);
   endfunction

endclass
`endif
