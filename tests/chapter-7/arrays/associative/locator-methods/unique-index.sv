// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: array-locator-methods-unique-index
:description: Test support of array locator methods
:tags: 7.12.1 7.12 7.10 7.12.2
:type: simulation elaboration parsing
:unsynthesizable: 1
*/
module top ();

int s[] = { 10, 10, 3, 20, 20, 10 };
int qi[$];

initial begin
	qi = s.unique_index;
    $display(":assert: (%d == 3)", qi.size);
	begin
		int v[$];
		foreach (qi[i]) v.push_back(s[qi[i]]);
		v.sort;
		$display(":assert: ((%d == 3) and (%d == 10) and (%d == 20))",
			v[0], v[1], v[2]);
	end
end

endmodule
