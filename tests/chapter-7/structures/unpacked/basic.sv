// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: basic-unpacked-structures
:description: Test unpacked structures support
:tags: 7.2 7.1
:type: simulation elaboration parsing
*/
module top ();

struct {
	bit [3:0] lo;
	bit [3:0] hi;
} p1;

initial begin
	p1.lo = 4'h5;
	p1.hi = 4'ha;
	$display(":assert: (('%h' == 'a') and ('%h' == '5'))", p1.hi, p1.lo);
end

endmodule
