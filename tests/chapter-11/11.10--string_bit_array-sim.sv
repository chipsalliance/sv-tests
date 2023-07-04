// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: string_bit_array_sim
:description: string stored in bit array simulation test
:type: simulation elaboration parsing
:tags: 11.10
*/
module top();

bit [8*14:1] a;

initial begin
	a = "Test";
    $display(":assert: ('Test' == '%0s')", a);
end

endmodule
