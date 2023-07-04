// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: typename_function
:description: $typename test
:tags: 20.6
:type: simulation elaboration parsing
*/

module top();

initial begin
	logic val;
	$display(":assert: ('%s' == 'logic')", $typename(val));
end

endmodule
