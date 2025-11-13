// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: foreach_loop_synth
:description: A module testing foreach loop
:tags: 12.7.3
*/
module test ();
  logic [15:0] test [4] = '{16'h1111, 16'h2222, 16'h3333, 16'h4444};
  logic [15:0] copy [4];
  always_comb begin
    foreach(test[i]) begin
      copy[i] = test[i];
    end
  end
endmodule
