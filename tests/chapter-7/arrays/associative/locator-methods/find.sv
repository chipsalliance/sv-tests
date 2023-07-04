// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: array-locator-methods-find
:description: Test support of array locator methods
:tags: 7.12.1 7.12 7.10
:type: simulation elaboration parsing
*/
module top ();

string s[] = { "hello", "sad", "world" };
string qs[$];

initial begin
	qs = s.find with ( item == "sad" );
    $display(":assert: (%d == 1)", qs.size);
    $display(":assert: ('%s' == 'sad')", qs[0]);
end

endmodule
