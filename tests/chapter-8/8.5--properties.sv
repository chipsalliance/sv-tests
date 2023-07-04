// Copyright (C) 2019-2021  The SymbiFlow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC


/*
:name: properties
:description: class properties test
:tags: 8.5
:type: simulation elaboration parsing
*/
module class_tb ();
	class test_cls;
		int a;
	endclass

	test_cls test_obj;

	initial begin
		test_obj = new;

		test_obj.a = 12;

		$display(":assert:(%d == 12)", test_obj.a);
	end
endmodule
