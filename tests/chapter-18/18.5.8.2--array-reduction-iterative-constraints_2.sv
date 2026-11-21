// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: array_reduction_iterative_constraints_2
:description: array reduction constraint over a dynamic array whose size is itself random
:tags: 18.5.8.2
*/

class a;
    rand int unsigned n;
    rand int B[];
    constraint c_n    { n inside {[2:4]}; }
    constraint c_size { B.size() == n; }
    constraint c_elem { foreach (B[i]) B[i] inside {[0:50]}; }
    constraint c_sum  { B.sum() == 100; }
    constraint c_order { solve n before B; }
endclass
