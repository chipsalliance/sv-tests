// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: function_fork_valid
:description: function valid fork test
:tags: 13.4.4
:type: simulation elaboration parsing
*/
module top();

function int fun(int val);
	fork
		$display("abc");
		$display("def");
	join_none
	return val + 2;
endfunction

initial
	$display("$d", fun(2));

endmodule
