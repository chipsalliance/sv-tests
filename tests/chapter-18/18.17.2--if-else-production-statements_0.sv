// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: if_else_production_statements_0
:description: randcase if-else test
:type: simulation elaboration parsing
:tags: 18.17.2
:unsynthesizable: 1
*/

function int F();
    int x;
    int switch = 1;
    randsequence( main )
      main : first;
      first : { if(switch) x = 10; else x = 5; };
    endsequence
    return x;
endfunction

module top;
   int x;
   initial begin
      x = F();
      if (x != 10) $stop;
   end
endmodule
