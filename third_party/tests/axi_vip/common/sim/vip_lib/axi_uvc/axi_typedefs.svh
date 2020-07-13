// -*- coding: utf-8 -*-
//
// Copyright (C) 2020 The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
// SPDX-License-Identifier: ISC

`ifndef _AXI_TYPEDEFS_SVH_
`define _AXI_TYPEDEFS_SVH_

typedef enum {
              AXI_WR,
              AXI_RD,
              AXI_AW,
              AXI_W,
              AXI_B,
              AXI_AR,
              AXI_R
             } axi_trans_type;

typedef enum {
              RAND,
              INCR,
              CONST
             } wr_data_type;

`endif
