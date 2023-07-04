// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: repl_op_sim
:description: replication operator simulation test
:type: simulation elaboration parsing
:tags: 11.4.12.1
*/
module top();

bit [15:0] a;

bit [1:0] b = 2'b10;

initial begin
	a = {8{b}};
    $display(":assert: (0b1010101010101010 == %d)", a);
end

endmodule
