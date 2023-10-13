// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: aborting_productions_break_and_return_2
:description: return statement test
:type: simulation elaboration parsing
:tags: 18.17.6
:unsynthesizable: 1
*/

function int F();
    int x;
    static int return_on = 1;
    randsequence( main )
      main : first second third;
      first : { x = x + 20; };
      second : { if(return_on == 1) return; x = x + 10; };
      third : { x = x + 5;};
    endsequence
    return x;
endfunction

module top;
   int x;
   initial begin
      x = F();
      $display(":assert: (25 == %d)", x);
   end
endmodule
