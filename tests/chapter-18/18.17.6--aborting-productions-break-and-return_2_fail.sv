// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: aborting_productions_break_and_return_2_fail
:description: return statement test
:should_fail_because: typo in production name
:type: elaboration
:tags: 18.17.6
:unsynthesizable: 1
*/

function int F();
    int x;
    static int return_on = 1;
    randsequence( main )
      main : first secondi third;
      first : { x = x + 20; };
      second : { if(return_on == 1) return; x = x + 10; };
      third : { x = x + 5;};
    endsequence
    return x;
endfunction
