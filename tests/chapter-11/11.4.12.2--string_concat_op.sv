// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: string_concat_op
:description: string concatenation operator test
:tags: 11.4.12.2
:type: simulation elaboration parsing
*/
module top();

string str;

initial begin
	str = {"Hello", "_", "World", "!"};
	$display(":assert:('%s' == 'Hello_World!')", str);
end

endmodule
