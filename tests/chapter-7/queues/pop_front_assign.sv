// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: pop_front-assign
:description: Update queue by assignment (pop_front)
:tags: 7.10.4
:type: simulation elaboration parsing
*/
module top ();

int q[$];
int r;

initial begin
	q.push_back(2);
	q.push_back(3);
	q.push_back(4);
	r = q[0];
	q = q[1:$];
	$display(":assert: (%d == 2)", q.size);
	$display(":assert: (%d == 2)", r);
	$display(":assert: (%d == 3)", q[0]);
end

endmodule
