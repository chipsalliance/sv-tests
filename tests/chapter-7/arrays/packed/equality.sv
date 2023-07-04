// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: operations-on-packed-arrays-equality
:description: Test packed arrays operations support (equality)
:tags: 7.4.3
:type: simulation elaboration parsing
*/
module top ();

bit [7:0] arr_a;
bit [7:0] arr_b;

initial begin
	arr_a = 8'hff;
	arr_b = 8'hff;
	$display(":assert: (('%h' == 'ff') and ('%h' == 'ff'))", arr_a, arr_b);

	$display(":assert: (%d == 1)", (arr_a == arr_b));
	$display(":assert: (%d == 0)", (arr_a != arr_b));
end

endmodule
