// Copyright (C) 2026  The CHIPS Alliance Authors.
//
// Use of this source code is governed by an ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC

/*
:name: event_control_posedge_constant_zero
:description: A constant zero never produces a positive edge
:tags: 9.4.2
*/
module top ();
  always @(posedge 1'd0) begin
  end
endmodule
