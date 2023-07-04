// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: nested_repl_op_sim
:description: nested replication operator simulation test
:type: simulation elaboration parsing
:tags: 11.4.12.1
*/
module top();

bit [15:0] a;

bit [1:0] b = 2'b10;
bit [1:0] c = 2'b01;
bit [3:0] d = 4'b1111;

initial begin
	a = {{3{b, c}}, d};
    $display(":assert: (0b1001100110011111 == %d)", a);
end

endmodule
