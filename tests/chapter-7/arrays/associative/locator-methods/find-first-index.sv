// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: array-locator-methods-find-first-index
:description: Test support of array locator methods
:tags: 7.12.1 7.12 7.10
:type: simulation elaboration parsing
*/
module top ();

string s[] = { "hello", "sad", "hello", "world" };
int qi[$];

initial begin
	qi = s.find_first_index with ( item == "hello" );
    $display(":assert: (%d == 1)", qi.size);
    $display(":assert: (%d == 0)", qi[0]);
end

endmodule
