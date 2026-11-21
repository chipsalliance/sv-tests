// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: uniqueness_constraints_4
:description: uniqueness constraints test - unique{} over a row of a 2D array
:tags: 18.5.5
*/

class a;
    rand bit [4:0] grid[3][3];
    constraint c1 { foreach (grid[i,j]) grid[i][j] inside {[1:9]}; }
    constraint c2 { foreach (grid[i]) unique {grid[i]}; }
endclass
