// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: uniqueness_constraints_2
:description: uniqueness constraints test - unique{} over an array, not just scalars
:tags: 18.5.5
*/

class a;
    rand bit [3:0] tags[6];
    constraint c1 { unique {tags}; }
endclass
