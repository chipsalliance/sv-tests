// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: array-unpacked-assignments
:description: Test unpacked arrays assignments
:tags: 7.6 7.4.2
:type: simulation elaboration parsing
*/
module top ();

int A [3:0];
int B [0:3];

initial begin
	A[0] = 0;
	A[1] = 1;
	A[2] = 2;
	A[3] = 3;

	B = A;

	$display(":assert: ((%d == 0) and (%d == 1) and (%d == 2) and (%d == 3))",
		B[3], B[2], B[1], B[0]);
end

endmodule
