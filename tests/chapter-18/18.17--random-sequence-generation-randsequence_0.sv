// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: random_sequence_generation_randsequence_0
:description: randsequence test
:type: simulation elaboration parsing
:tags: 18.17
:unsynthesizable: 1
*/

function int F();
    int x;
    randsequence( main )
        main : first second done;
        first : { x = x + 1; };
        second : { x = x + 2; };
        done : { x = x + 3; };
    endsequence
    return x;
endfunction

module top;
   int x;
   initial begin
      x = F();
      $display(":assert: (6 == %d)", x);
   end
endmodule
