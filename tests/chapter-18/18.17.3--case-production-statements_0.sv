// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: case_production_statements_0
:description: randcase case statement test
:type: simulation elaboration parsing
:tags: 18.17.3
:unsynthesizable: 1
*/

function int F();
    int x;
    int switch = 1;
    randsequence( main )
      main : case (switch)
          0 : zero;
          1 : first;
          2 : second;
          default : third;
      endcase;
      zero : { x = 0; };
      first : { x = 10; };
      second : { x = 2; };
      third : { x = 3; };
    endsequence

    return x;
endfunction

module top;
   int x;
   initial begin
      x = F();
      $display(":assert: (10 == %d)", x);
   end
endmodule
