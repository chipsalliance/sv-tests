// -*- coding: utf-8 -*-
//
// Copyright (C) 2020 The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
// SPDX-License-Identifier: ISC

`ifndef _SVTB_SCOREBOARD_CONFIG_SVH_
`define _SVTB_SCOREBOARD_CONFIG_SVH_

class svtb_scoreboard_config extends uvm_object;
   `uvm_object_utils(svtb_scoreboard_config)

   function new(string name = "svtb_scoreboard_config");
      super.new(name);
   endfunction

   bit     outoforder;
   event   flush_sb;

endclass
`endif
