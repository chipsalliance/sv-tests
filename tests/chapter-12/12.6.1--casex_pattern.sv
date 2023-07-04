// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: casex_pattern
:description: A module testing pattern matching in casex statements
:tags: 12.6.1
*/
module case_tb ();

	typedef union tagged {
		struct {
			bit [3:0] val1, val2;
		} a;
		struct {
			bit [7:0] val1, val2;
		} b;
		struct {
			bit [15:0] val1, val2;
		} c;
	} u;

	u tmp;

	initial casex (tmp) matches
		tagged a '{.v, 4'b00?x} : $display("a %d", v);
		tagged a '{.v1, .v2} : $display("a %d %d", v1, v2);
		tagged b '{.v1, .v2} : $display("b %d %d", v1, v2);
		tagged c '{4'h??0x, .v} : $display("c %d", v);
	endcase
endmodule
