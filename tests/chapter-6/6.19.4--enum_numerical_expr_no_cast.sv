// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: enum_numerical_expr_no_cast
:description: enum numerical expression without casting
:should_fail_because: enum numerical expression without casting
:tags: 6.19.4
:type: simulation elaboration
*/
module top();
	typedef enum {a, b, c, d} e;

	initial begin
		e val;
		val = a;
		val += 1;
	end
endmodule
