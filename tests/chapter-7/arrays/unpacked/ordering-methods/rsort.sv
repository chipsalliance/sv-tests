// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: ordering-methods-rsort
:description: Test support of rsort method on unpacked arrays
:tags: 7.12.2 7.4.2
:type: simulation elaboration parsing
*/
module top ();

int ia[] = { 4, 5, 3, 1 };

initial begin
	$display(":assert: ((%d == 4) and (%d == 5) and (%d == 3) and (%d == 1))",
		ia[0], ia[1], ia[2], ia[3]);
	ia.rsort;
	$display(":assert: ((%d == 5) and (%d == 4) and (%d == 3) and (%d == 1))",
		ia[0], ia[1], ia[2], ia[3]);
end

endmodule
