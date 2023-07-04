// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: integers-underscores
:description: Automatic left padding of literal numbers using single-bit value
:tags: 5.7.1
*/
module top();
  logic [31:0] a;
  logic [15:0] b;
  logic [31:0] c;

  initial begin
    a = 27_195_000;              // unsized decimal 27195000
    b = 16'b0011_0101_0001_1111; // 16-bit binary number
    c = 32 'h 12ab_f001;         // 32-bit hexadecimal number
  end

endmodule
