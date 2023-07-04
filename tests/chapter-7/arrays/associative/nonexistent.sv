// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: associative-arrays-access-nonexistent
:description: Test access to nonexistent associative array element
:tags: 7.8.6 7.9.1
:type: simulation elaboration parsing
*/
module top ();

int arr [ int ];
int r;

initial begin
	arr[10] = 10;
	$display(":assert: (%d == 1)", arr.size);

	// access nonexistent element
	$display(":re: BEGIN:ARRAY_NONEXISTENT");
	r = arr[9];
	$display(":re: END");
end

endmodule
