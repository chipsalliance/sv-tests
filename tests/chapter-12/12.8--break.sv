// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: jump_break
:description: A module testing break statement
:tags: 12.8
:type: simulation elaboration parsing
*/
module jump_tb ();
	initial begin
		int i;
		for (i = 0; i < 256; i++)begin
			if(i > 100)
				break;
		end
		$display(":assert:(%d == 101)", i);
	end
endmodule
