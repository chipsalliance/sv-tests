// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: structure
:description: Structure assignment tests
:tags: 5.10
*/
module top();
  typedef struct {
    int a;
    int b;
  } ms_t;

  ms_t ms;

  initial begin
    ms = '{ 0, 1};

    ms = '{ default:1, int:1};

    ms = '{ int:0, int:1};
  end

endmodule
