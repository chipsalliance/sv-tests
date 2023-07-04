// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: string-broken-line
:description: Basic broken line string example
:tags: 5.9
*/
module top();

  initial begin
    $display("broken \
              line");
  end

endmodule
