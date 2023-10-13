// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: if_else_production_statements_2_fail
:description: randcase if-else test
:should_fail_because: switch variable not declared
:type: elaboration
:tags: 18.17.2
:unsynthesizable: 1
*/

function int F();
    int x;
    randsequence( main )
      main : first;
      first : if(switch) second else third;
      second : { x = 10; };
      third : { x = 5; };
    endsequence
    return x;
endfunction
